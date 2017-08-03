require 'ostruct'
require 'securerandom'

RSpec.shared_examples 'migrator_sqlite' do
  let(:migrator) do
    Hanami::Model::Migrator.new(configuration: configuration)
  end

  let(:random) { SecureRandom.hex }

  # General variables
  let(:migrations)     { Pathname.new(__dir__ + '/../../../../support/fixtures/migrations') }
  let(:schema)         { nil }
  let(:config)         { OpenStruct.new(backend: :sql, url: url, _migrations: migrations, _schema: schema, migrations_logger: Hanami::Model::Migrator::Logger.new(ENV['HANAMI_DATABASE_LOGGER'])) }
  let(:configuration)  { Hanami::Model::Configuration.new(config) }
  let(:url) do
    db = database

    Platform.match do
      engine(:ruby)  { "sqlite://#{db}" }
      engine(:jruby) { "jdbc:sqlite://#{db}" }
    end
  end

  # Variables for `apply` and `prepare`
  let(:root)              { Pathname.new("#{__dir__}/../../../../../tmp").expand_path }
  let(:source_migrations) { Pathname.new("#{__dir__}/../../../../support/fixtures/migrations") }
  let(:target_migrations) { root.join("migrations-#{random}") }

  after do
    migrator.drop rescue nil # rubocop:disable Style/RescueModifier
  end

  describe 'SQLite filesystem' do
    let(:database) do
      Pathname.new("#{__dir__}/../../../../../tmp/create-#{random}.sqlite3").expand_path
    end

    describe 'create' do
      it 'creates the database' do
        migrator.create
        expect(File.exist?(database)).to be_truthy, "Expected database #{database} to exist"
      end

      describe "when it doesn't have write permissions" do
        let(:database) { '/usr/bin/create.sqlite3' }

        it 'raises an error' do
          error = Platform.match do
            os(:macos).engine(:jruby) { Java::JavaLang::RuntimeException }
            default { Hanami::Model::MigrationError }
          end

          message = Platform.match do
            os(:macos).engine(:jruby) { 'Unhandled IOException: java.io.IOException: unhandled errno: Operation not permitted' }
            default { 'Permission denied: /usr/bin/create.sqlite3' }
          end

          expect { migrator.create }.to raise_error(error, message)
        end
      end

      describe 'when the path is relative' do
        let(:database) { 'create.sqlite3' }

        it 'creates the database' do
          migrator.create
          expect(File.exist?(database)).to be_truthy, "Expected database #{database} to exist"
        end
      end
    end

    describe 'drop' do
      before do
        migrator.create
      end

      it 'drops the database' do
        migrator.drop
        expect(File.exist?(database)).to be_falsey, "Expected database #{database} to NOT exist"
      end

      it "raises error if database doesn't exist" do
        migrator.drop # remove the first time

        expect { migrator.drop }
          .to raise_error(Hanami::Model::MigrationError, "Cannot find database: #{database}")
      end
    end

    describe 'migrate' do
      before do
        migrator.create
      end

      describe 'when no migrations' do
        let(:migrations) { Pathname.new(__dir__ + '/../../../../support/fixtures/empty_migrations') }

        it "it doesn't alter database" do
          migrator.migrate

          connection = Sequel.connect(url)
          expect(connection.tables).to be_empty
        end
      end

      describe 'when migrations are present' do
        it 'migrates the database' do
          migrator.migrate

          connection = Sequel.connect(url)
          expect(connection.tables).to_not be_empty

          table = connection.schema(:reviews)

          name, options = table[0] # id
          expect(name).to eq(:id)

          expect(options.fetch(:allow_null)).to eq(false)
          expect(options.fetch(:default)).to be_nil
          expect(options.fetch(:type)).to eq(:integer)
          expect(options.fetch(:db_type)).to eq('integer')
          expect(options.fetch(:primary_key)).to eq(true)
          expect(options.fetch(:auto_increment)).to eq(true)

          name, options = table[1] # title
          expect(name).to eq(:title)

          expect(options.fetch(:allow_null)).to eq(false)
          expect(options.fetch(:default)).to be_nil
          expect(options.fetch(:type)).to eq(:string)
          expect(options.fetch(:db_type)).to eq('varchar(255)')
          expect(options.fetch(:primary_key)).to eq(false)

          name, options = table[2] # rating (second migration)
          expect(name).to eq(:rating)

          expect(options.fetch(:allow_null)).to eq(true)
          expect(options.fetch(:default)).to eq('0')
          expect(options.fetch(:type)).to eq(:integer)
          expect(options.fetch(:db_type)).to eq('integer')
          expect(options.fetch(:primary_key)).to eq(false)
        end
      end

      describe 'when migrations are ran twice' do
        before do
          migrator.migrate
        end

        it "doesn't alter the schema" do
          migrator.migrate

          connection = Sequel.connect(url)
          expect(connection.tables).to_not be_empty
          expect(connection.tables).to eq([:schema_migrations, :reviews])
        end
      end

      describe 'migrate down' do
        before do
          migrator.migrate
        end

        it 'migrates the database' do
          migrator.migrate(version: '20160831073534') # see spec/support/fixtures/migrations

          connection = Sequel.connect(url)
          expect(connection.tables).to_not be_empty

          table = connection.schema(:reviews)

          name, options = table[0] # id
          expect(name).to eq(:id)

          expect(options.fetch(:allow_null)).to eq(false)
          expect(options.fetch(:default)).to be_nil
          expect(options.fetch(:type)).to eq(:integer)
          expect(options.fetch(:db_type)).to eq('integer')
          expect(options.fetch(:primary_key)).to eq(true)
          expect(options.fetch(:auto_increment)).to eq(true)

          name, options = table[1] # title
          expect(name).to eq(:title)

          expect(options.fetch(:allow_null)).to eq(false)
          expect(options.fetch(:default)).to be_nil
          expect(options.fetch(:type)).to eq(:string)
          expect(options.fetch(:db_type)).to eq('varchar(255)')
          expect(options.fetch(:primary_key)).to eq(false)

          name, options = table[2] # rating (rolled back second migration)
          expect(name).to be_nil
          expect(options).to be_nil
        end
      end
    end

    describe 'apply' do
      let(:migrations) { target_migrations }
      let(:schema)     { root.join("schema-sqlite-#{random}.sql") }

      before do
        prepare_migrations_directory
      end

      after do
        clean_migrations
      end

      it 'migrates to latest version' do
        migrator.apply
        connection = Sequel.connect(url)
        migration = connection[:schema_migrations].to_a.last

        expect(migration.fetch(:filename)).to include('20160831090612') # see spec/support/fixtures/migrations
      end

      it 'dumps database schema.sql' do
        migrator.apply
        actual = schema.read

        expect(actual).to include %(CREATE TABLE `schema_migrations` (`filename` varchar(255) NOT NULL PRIMARY KEY);)
        expect(actual).to include %(CREATE TABLE `reviews` (`id` integer NOT NULL PRIMARY KEY AUTOINCREMENT, `title` varchar(255) NOT NULL, `rating` integer DEFAULT (0));)
        expect(actual).to include %(INSERT INTO "schema_migrations" VALUES('20160831073534_create_reviews.rb');)
        expect(actual).to include %(INSERT INTO "schema_migrations" VALUES('20160831090612_add_rating_to_reviews.rb');)
      end

      it 'deletes all the migrations' do
        migrator.apply
        expect(target_migrations.children).to be_empty
      end

      context "when a system call fails" do
        before do
          expect(migrator).to receive(:adapter).at_least(:once).and_return(adapter)
        end

        let(:adapter) { Hanami::Model::Migrator::Adapter.for(configuration) }

        it "raises error when fails to dump database structure" do
          expect(adapter).to receive(:dump_structure).and_raise(Hanami::Model::MigrationError, message = "there was a problem")
          expect { migrator.apply }.to raise_error(Hanami::Model::MigrationError, message)

          expect(target_migrations.children).to_not be_empty
        end

        it "raises error when fails to dump migrations data" do
          expect(adapter).to receive(:dump_migrations_data).and_raise(Hanami::Model::MigrationError, message = "there was another problem")
          expect { migrator.apply }.to raise_error(Hanami::Model::MigrationError, message)

          expect(target_migrations.children).to_not be_empty
        end

        it "raises error when fails to write migrations data" do
          expect(File).to receive(:open).and_raise(StandardError, message = "a standard error")
          expect { migrator.apply }.to raise_error(Hanami::Model::MigrationError, message)

          expect(target_migrations.children).to_not be_empty
        end
      end
    end

    describe 'prepare' do
      let(:migrations) { target_migrations }
      let(:schema)     { root.join("schema-sqlite-#{random}.sql") }

      before do
        prepare_migrations_directory
      end

      after do
        clean_migrations
      end

      it 'creates database, loads schema and migrate' do
        # Simulate already existing schema.sql, without existing database and pending migrations
        connection = Sequel.connect(url)
        Hanami::Model::Migrator::Adapter.for(configuration).dump

        migration = target_migrations.join('20160831095616_create_abuses.rb')
        File.open(migration, 'w+') do |f|
          f.write <<-RUBY
Hanami::Model.migration do
  change do
    create_table :abuses do
      primary_key :id
    end
  end
end
RUBY
        end

        migrator.prepare

        expect(connection.tables).to eq([:schema_migrations, :reviews, :abuses])

        FileUtils.rm_f migration
      end

      it "works even if schema doesn't exist" do
        # Simulate no database, no schema and pending migrations
        FileUtils.rm_f schema
        migrator.prepare

        connection = Sequel.connect(url)
        expect(connection.tables).to eq([:schema_migrations, :reviews])
      end

      it 'drops the database and recreate it' do
        migrator.create
        migrator.prepare

        connection = Sequel.connect(url)
        expect(connection.tables).to include(:schema_migrations)
        expect(connection.tables).to include(:reviews)
      end
    end

    describe 'version' do
      before do
        migrator.create
      end

      describe 'when no migrations were ran' do
        it 'returns nil' do
          expect(migrator.version).to be_nil
        end
      end

      describe 'with migrations' do
        before do
          migrator.migrate
        end

        it 'returns current database version' do
          expect(migrator.version).to eq('20160831090612') # see spec/support/fixtures/migrations)
        end
      end
    end
  end

  private

  def prepare_migrations_directory
    target_migrations.mkpath
    FileUtils.cp_r(Dir.glob("#{source_migrations}/*.rb"), target_migrations)
  end

  def clean_migrations
    FileUtils.rm_rf(target_migrations)
    FileUtils.rm(schema) if schema.exist?
  end
end
