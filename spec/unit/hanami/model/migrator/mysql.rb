require 'ostruct'
require 'securerandom'

RSpec.shared_examples 'migrator_mysql' do
  let(:migrator) do
    Hanami::Model::Migrator.new(configuration: configuration)
  end

  let(:random) { SecureRandom.hex(4) }

  # General variables
  let(:migrations)     { Pathname.new(__dir__ + '/../../../../support/fixtures/migrations') }
  let(:schema)         { nil }
  let(:config)         { OpenStruct.new(backend: :sql, url: url, _migrations: migrations, _schema: schema, migrations_logger: Hanami::Model::Migrator::Logger.new(ENV['HANAMI_DATABASE_LOGGER'])) }
  let(:configuration)  { Hanami::Model::Configuration.new(config) }

  # Variables for `apply` and `prepare`
  let(:root)              { Pathname.new("#{__dir__}/../../../../../tmp").expand_path }
  let(:source_migrations) { Pathname.new("#{__dir__}/../../../../support/fixtures/migrations") }
  let(:target_migrations) { root.join("migrations-#{random}") }

  after do
    migrator.drop rescue nil # rubocop:disable Style/RescueModifier
  end

  describe 'MySQL' do
    let(:database) { "mysql_#{random}" }

    let(:url) do
      db = database
      credentials = [
        ENV['HANAMI_DATABASE_USERNAME'],
        ENV['HANAMI_DATABASE_PASSWORD']
      ].compact.join(":")

      Platform.match do
        engine(:ruby) { "mysql2://#{credentials}@#{ENV['HANAMI_DATABASE_HOST']}/#{db}?user=#{ENV['HANAMI_DATABASE_USERNAME']}" }
        engine(:jruby) { "jdbc:mysql://localhost/#{db}?user=#{ENV['HANAMI_DATABASE_USERNAME']}&useSSL=false" }
      end
    end

    describe 'create' do
      it 'creates the database' do
        migrator.create

        connection = Sequel.connect(url)
        expect(connection.tables).to be_empty
      end

      it "raises error when can't connect to database" do
        expect(Sequel).to receive(:connect).at_least(:once).and_raise(Sequel::DatabaseError.new("ouch"))

        expect { migrator.create }.to raise_error do |error|
          expect(error).to be_a(Hanami::Model::MigrationError)
          expect(error.message).to eq("ouch")
        end
      end

      it 'raises error if database is busy' do
        migrator.create
        Sequel.connect(url).tables

        expect { migrator.create }.to raise_error do |error|
          expect(error).to be_a(Hanami::Model::MigrationError)
          expect(error.message).to include('Database creation failed. If the database exists,')
          expect(error.message).to include('then its console may be open. See this issue for more details:')
          expect(error.message).to include('https://github.com/hanami/model/issues/250')
        end
      end

      # See https://github.com/hanami/model/issues/381
      describe 'when database name contains a dash' do
        let(:database) { "db-name-create_#{random}" }

        it 'creates the database' do
          migrator.create

          connection = Sequel.connect(url)
          expect(connection.tables).to be_empty
        end
      end
    end

    describe 'drop' do
      before do
        migrator.create
      end

      it 'drops the database' do
        migrator.drop
        expect { Sequel.connect(url).tables }.to raise_error(Sequel::DatabaseConnectionError)
      end

      it "raises error if database doesn't exist" do
        migrator.drop # remove the first time

        expect { migrator.drop }
          .to raise_error(Hanami::Model::MigrationError, "Cannot find database: #{database}")
      end

      it "raises error when can't connect to database" do
        expect(Sequel).to receive(:connect).at_least(:once).and_raise(Sequel::DatabaseError.new("ouch"))

        expect { migrator.drop }.to raise_error do |error|
          expect(error).to be_a(Hanami::Model::MigrationError)
          expect(error.message).to eq("ouch")
        end
      end

      # See https://github.com/hanami/model/issues/381
      describe 'when database name contains a dash' do
        let(:database) { "db-name-drop_#{random}" }

        it 'drops the database' do
          migrator.drop

          expect { Sequel.connect(url).tables }.to raise_error(Sequel::DatabaseConnectionError)
        end
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
          expect(options.fetch(:db_type)).to eq('int')
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
          expect(options.fetch(:db_type)).to eq('int')
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
          expect(connection.tables).to eq(%i[reviews schema_migrations])
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
          expect(options.fetch(:db_type)).to eq('int')
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

    describe 'rollback' do
      before do
        migrator.create
      end

      describe 'when no migrations' do
        let(:migrations) { Pathname.new(__dir__ + '/../../../../support/fixtures/empty_migrations') }

        it "it doesn't alter database" do
          migrator.rollback

          connection = Sequel.connect(url)
          expect(connection.tables).to be_empty
        end
      end

      describe 'when migrations are present' do
        it 'rollbacks one migration (default)' do
          migrator.migrate
          migrator.rollback

          connection = Sequel.connect(url)
          expect(connection.tables).to include(:reviews)

          table = connection.schema(:reviews)

          name, options = table[0] # id
          expect(name).to eq(:id)

          expect(options.fetch(:allow_null)).to eq(false)
          expect(options.fetch(:default)).to be_nil
          expect(options.fetch(:type)).to eq(:integer)
          expect(options.fetch(:db_type)).to eq('int')
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
          expect(name).to eq(nil)
          expect(options).to eq(nil)
        end

        it 'rollbacks several migrations' do
          migrator.migrate
          migrator.rollback(steps: 2)

          connection = Sequel.connect(url)
          expect(connection.tables).to eq([:schema_migrations])
        end
      end
    end

    describe 'apply' do
      let(:migrations) { target_migrations }
      let(:schema) { root.join("schema-#{random}.sql") }

      before do
        prepare_migrations_directory
        migrator.create
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

        expect(actual).to include %(DROP TABLE IF EXISTS `reviews`;)

        expect(actual).to include %(CREATE TABLE `reviews`)

        expect(actual).to include %(`id` int NOT NULL AUTO_INCREMENT,)

        expect(actual).to include %(`title` varchar(255))

        expect(actual).to include %(`rating` int DEFAULT '0',)
        expect(actual).to include %(PRIMARY KEY \(`id`\))

        expect(actual).to include %(DROP TABLE IF EXISTS `schema_migrations`;)

        expect(actual).to include %(CREATE TABLE `schema_migrations` \()

        expect(actual).to include %(`filename` varchar(255))
        expect(actual).to include %(PRIMARY KEY (`filename`))

        expect(actual).to include %(LOCK TABLES `schema_migrations` WRITE;)

        # expect(actual).to include %(INSERT INTO `schema_migrations` VALUES \('20150610133853_create_books.rb'\),\('20150610141017_add_price_to_books.rb'\);)

        expect(actual).to include %(UNLOCK TABLES;)
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
      end
    end

    describe 'prepare' do
      let(:migrations) { target_migrations }
      let(:schema)     { root.join("schema-#{random}.sql") }

      before do
        prepare_migrations_directory
        migrator.create
        migrator.migrate
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
          f.write <<~RUBY
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

        tables = connection.tables
        expect(tables).to include(:schema_migrations)
        expect(tables).to include(:reviews)
        expect(tables).to include(:abuses)

        FileUtils.rm_f migration
      end

      it "works even if schema doesn't exist" do
        # Simulate no database, no schema and pending migrations
        FileUtils.rm_f schema

        migrator.prepare

        connection = Sequel.connect(url)
        expect(connection.tables).to include(:schema_migrations)
        expect(connection.tables).to include(:reviews)
      end

      it 'drops the database and recreates it' do
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
