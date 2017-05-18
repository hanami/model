require 'ostruct'
require 'securerandom'

describe 'Filesystem SQLite Database migrations' do
  let(:migrator) do
    Hanami::Model::Migrator.new(configuration: configuration)
  end

  let(:random) { SecureRandom.hex }

  # General variables
  let(:migrations)     { Pathname.new(__dir__ + '/../fixtures/migrations') }
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
  let(:root)              { Pathname.new("#{__dir__}/../../tmp").expand_path }
  let(:source_migrations) { Pathname.new("#{__dir__}/../fixtures/migrations") }
  let(:target_migrations) { root.join("migrations-#{random}") }

  after do
    migrator.drop rescue nil # rubocop:disable Style/RescueModifier
  end

  describe 'SQLite filesystem' do
    let(:database) do
      Pathname.new("#{__dir__}/../../tmp/create-#{random}.sqlite3").expand_path
    end

    describe 'create' do
      it 'creates the database' do
        migrator.create
        assert File.exist?(database), "Expected database #{database} to exist"
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

          exception = -> { migrator.create }.must_raise error
          exception.message.must_equal message
        end
      end

      describe 'when the path is relative' do
        let(:database) { 'create.sqlite3' }

        it 'creates the database' do
          migrator.create
          assert File.exist?(database), "Expected database #{database} to exist"
        end
      end
    end

    describe 'drop' do
      before do
        migrator.create
      end

      it 'drops the database' do
        migrator.drop
        assert !File.exist?(database), "Expected database #{database} to NOT exist"
      end

      it "raises error if database doesn't exist" do
        migrator.drop # remove the first time

        exception = -> { migrator.drop }.must_raise Hanami::Model::MigrationError
        exception.message.must_equal "Cannot find database: #{database}"
      end
    end

    describe 'migrate' do
      before do
        migrator.create
      end

      describe 'when no migrations' do
        let(:migrations) { Pathname.new(__dir__ + '/../fixtures/empty_migrations') }

        it "it doesn't alter database" do
          migrator.migrate

          connection = Sequel.connect(url)
          connection.tables.must_be :empty?
        end
      end

      describe 'when migrations are present' do
        it 'migrates the database' do
          migrator.migrate

          connection = Sequel.connect(url)
          connection.tables.wont_be :empty?

          table = connection.schema(:reviews)

          name, options = table[0] # id
          name.must_equal :id

          options.fetch(:allow_null).must_equal false
          options.fetch(:default).must_be_nil
          options.fetch(:type).must_equal           :integer
          options.fetch(:db_type).must_equal        'integer'
          options.fetch(:primary_key).must_equal    true
          options.fetch(:auto_increment).must_equal true

          name, options = table[1] # title
          name.must_equal :title

          options.fetch(:allow_null).must_equal false
          options.fetch(:default).must_be_nil
          options.fetch(:type).must_equal           :string
          options.fetch(:db_type).must_equal        'varchar(255)'
          options.fetch(:primary_key).must_equal    false

          name, options = table[2] # rating (second migration)
          name.must_equal :rating

          options.fetch(:allow_null).must_equal     true
          options.fetch(:default).must_equal        '0'
          options.fetch(:type).must_equal           :integer
          options.fetch(:db_type).must_equal        'integer'
          options.fetch(:primary_key).must_equal    false
        end
      end

      describe 'when migrations are ran twice' do
        before do
          migrator.migrate
        end

        it "doesn't alter the schema" do
          migrator.migrate

          connection = Sequel.connect(url)
          connection.tables.wont_be :empty?
          connection.tables.must_equal [:schema_migrations, :reviews]
        end
      end

      describe 'migrate down' do
        before do
          migrator.migrate
        end

        it 'migrates the database' do
          migrator.migrate(version: '20160831073534') # see test/fixtures/migrations

          connection = Sequel.connect(url)
          connection.tables.wont_be :empty?

          table = connection.schema(:reviews)

          name, options = table[0] # id
          name.must_equal :id

          options.fetch(:allow_null).must_equal false
          options.fetch(:default).must_be_nil
          options.fetch(:type).must_equal           :integer
          options.fetch(:db_type).must_equal        'integer'
          options.fetch(:primary_key).must_equal    true
          options.fetch(:auto_increment).must_equal true

          name, options = table[1] # title
          name.must_equal :title

          options.fetch(:allow_null).must_equal false
          options.fetch(:default).must_be_nil
          options.fetch(:type).must_equal           :string
          options.fetch(:db_type).must_equal        'varchar(255)'
          options.fetch(:primary_key).must_equal    false

          name, options = table[2] # rating (rolled back second migration)
          name.must_be_nil
          options.must_be_nil
        end
      end
    end

    describe 'apply' do
      let(:migrations) { target_migrations }
      let(:schema)     { root.join("schema-sqlite-#{random}.sql") }

      before do
        prepare_migrations_directory
        migrator.apply
      end

      after do
        clean_migrations
      end

      it 'migrates to latest version' do
        connection = Sequel.connect(url)
        migration  = connection[:schema_migrations].to_a.last

        migration.fetch(:filename).must_include('20160831090612') # see test/fixtures/migrations
      end

      it 'dumps database schema.sql' do
        actual = schema.read

        actual.must_include %(CREATE TABLE `schema_migrations` (`filename` varchar(255) NOT NULL PRIMARY KEY);)
        actual.must_include %(CREATE TABLE `reviews` (`id` integer NOT NULL PRIMARY KEY AUTOINCREMENT, `title` varchar(255) NOT NULL, `rating` integer DEFAULT (0));)
        actual.must_include %(INSERT INTO "schema_migrations" VALUES('20160831073534_create_reviews.rb');)
        actual.must_include %(INSERT INTO "schema_migrations" VALUES('20160831090612_add_rating_to_reviews.rb');)
      end

      it 'deletes all the migrations' do
        target_migrations.children.must_be :empty?
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

        connection.tables.must_equal [:schema_migrations, :reviews, :abuses]

        FileUtils.rm_f migration
      end

      it "works even if schema doesn't exist" do
        # Simulate no database, no schema and pending migrations
        FileUtils.rm_f schema
        migrator.prepare

        connection = Sequel.connect(url)
        connection.tables.must_equal [:schema_migrations, :reviews]
      end

      it 'drops the database and recreate it' do
        migrator.create
        migrator.prepare

        connection = Sequel.connect(url)
        connection.tables.must_include(:schema_migrations)
        connection.tables.must_include(:reviews)
      end
    end

    describe 'version' do
      before do
        migrator.create
      end

      describe 'when no migrations were ran' do
        it 'returns nil' do
          migrator.version.must_be_nil
        end
      end

      describe 'with migrations' do
        before do
          migrator.migrate
        end

        it 'returns current database version' do
          migrator.version.must_equal '20160831090612' # see test/fixtures/migrations
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
