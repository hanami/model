require 'ostruct'

describe 'PostgreSQL Database migrations' do
  let(:migrator) do
    Hanami::Model::Migrator.new(configuration: configuration)
  end

  let(:random) { SecureRandom.hex(4) }

  # General variables
  let(:adapter_prefix) { 'jdbc:' if Hanami::Utils.jruby? }
  let(:migrations)     { Pathname.new(__dir__ + '/../fixtures/migrations') }
  let(:schema)         { nil }
  let(:config)         { OpenStruct.new(backend: :sql, url: url, _migrations: migrations, _schema: schema) }
  let(:configuration)  { Hanami::Model::Configuration.new(config) }

  # Variables for `apply` and `prepare`
  let(:root)              { Pathname.new("#{__dir__}/../../tmp").expand_path }
  let(:source_migrations) { Pathname.new("#{__dir__}/../fixtures/migrations") }
  let(:target_migrations) { root.join("migrations-#{random}") }

  after do
    migrator.drop rescue nil # rubocop:disable Style/RescueModifier
  end

  describe 'PostgreSQL' do
    let(:database) { "#{name.gsub(/[^\w]/, '_')}_#{random}" }
    let(:url)      { "#{adapter_prefix}postgresql://127.0.0.1/#{database}?user=#{ENV['HANAMI_DATABASE_USERNAME']}" }

    describe 'create' do
      before do
        migrator.create
      end

      it 'creates the database' do
        connection = Sequel.connect(url)
        connection.tables.must_be :empty?
      end

      it 'raises error if database is busy' do
        Sequel.connect(url).tables
        exception = -> { migrator.create }.must_raise Hanami::Model::MigrationError
        exception.message.must_include 'createdb: database creation failed'
        exception.message.must_include 'There is 1 other session using the database'
      end

      describe "when a command isn't available" do
        before do
          # We accomplish having a command not be available by setting PATH
          # to an empty string, which means *no commands* are available.
          @original_path = ENV['PATH']
          ENV['PATH']    = ''
        end

        after do
          ENV['PATH'] = @original_path
        end

        it 'raises MigrationError on create' do
          message = Platform.match do
            os(:macos).engine(:jruby) { 'Unknown error - createdb' }
            default                   { 'No such file or directory - createdb' }
          end

          exception = -> { migrator.create }.must_raise Hanami::Model::MigrationError
          exception.message.must_equal message
        end
      end
    end

    describe 'drop' do
      before do
        migrator.create
      end

      it 'drops the database' do
        migrator.drop

        -> { Sequel.connect(url).tables }.must_raise Sequel::DatabaseConnectionError
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

          options.fetch(:allow_null).must_equal     false
          options.fetch(:default).must_equal        "nextval('reviews_id_seq'::regclass)"
          options.fetch(:type).must_equal           :integer
          options.fetch(:db_type).must_equal        'integer'
          options.fetch(:primary_key).must_equal    true
          options.fetch(:auto_increment).must_equal true

          name, options = table[1] # title
          name.must_equal :title

          options.fetch(:allow_null).must_equal     false
          options.fetch(:default).must_equal        nil
          options.fetch(:type).must_equal           :string
          options.fetch(:db_type).must_equal        'text'
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
          connection.tables.must_include :schema_migrations
          connection.tables.must_include :reviews
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

          options.fetch(:allow_null).must_equal     false
          options.fetch(:default).must_equal        "nextval('reviews_id_seq'::regclass)"
          options.fetch(:type).must_equal           :integer
          options.fetch(:db_type).must_equal        'integer'
          options.fetch(:primary_key).must_equal    true
          options.fetch(:auto_increment).must_equal true

          name, options = table[1] # title
          name.must_equal :title

          options.fetch(:allow_null).must_equal     false
          options.fetch(:default).must_equal        nil
          options.fetch(:type).must_equal           :string
          options.fetch(:db_type).must_equal        'text'
          options.fetch(:primary_key).must_equal    false

          name, options = table[2] # rating (rolled back second migration)
          name.must_be_nil
          options.must_be_nil
        end
      end
    end

    describe 'apply' do
      let(:migrations) { target_migrations }
      let(:schema)     { root.join("schema-postgresql-#{random}.sql") }

      before do
        prepare_migrations_directory
        migrator.create
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

        actual.must_include <<-SQL
CREATE TABLE reviews (
    id integer NOT NULL,
    title text NOT NULL,
    rating integer DEFAULT 0
);
        SQL

        actual.must_include <<-SQL
CREATE SEQUENCE reviews_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
        SQL

        actual.must_include <<-SQL
ALTER SEQUENCE reviews_id_seq OWNED BY reviews.id;
        SQL

        actual.must_include <<-SQL
ALTER TABLE ONLY reviews ALTER COLUMN id SET DEFAULT nextval('reviews_id_seq'::regclass);
        SQL

        actual.must_include <<-SQL
ALTER TABLE ONLY reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (id);
        SQL

        actual.must_include <<-SQL
CREATE TABLE schema_migrations (
    filename text NOT NULL
);
        SQL

        actual.must_include <<-SQL
COPY schema_migrations (filename) FROM stdin;
20160831073534_create_reviews.rb
20160831090612_add_rating_to_reviews.rb
        SQL

        actual.must_include <<-SQL
ALTER TABLE ONLY schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (filename);
        SQL
      end

      it 'deletes all the migrations' do
        target_migrations.children.must_be :empty?
      end
    end

    describe 'prepare' do
      let(:migrations) { target_migrations }
      let(:schema)     { root.join("schema-postgresql-#{random}.sql") }

      before do
        prepare_migrations_directory
        migrator.create
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

        tables = connection.tables
        tables.must_include(:schema_migrations)
        tables.must_include(:reviews)
        tables.must_include(:abuses)

        FileUtils.rm_f migration
      end

      it "works even if schema doesn't exist" do
        # Simulate no database, no schema and pending migrations
        FileUtils.rm_f schema

        migrator.prepare

        connection = Sequel.connect(url)
        connection.tables.must_include(:schema_migrations)
        connection.tables.must_include(:reviews)
      end

      it 'drops the database and recreates it' do
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
