require 'test_helper'
require 'lotus/model/migrator'

describe 'PostgreSQL Database migrations' do
  let(:adapter_prefix) { 'jdbc:' if Lotus::Utils.jruby?  }
  let(:db_prefix)      { name.gsub(/[^\w]/, '_') }
  let(:random_token)   { SecureRandom.hex(4) }

  before do
    Lotus::Model.unload!
  end

  after do
    Lotus::Model::Migrator.drop rescue nil
    Lotus::Model.unload!
  end

  describe "PostgreSQL" do
    before do
      @database  = "#{ db_prefix }_#{ random_token }"
      @uri       = uri = "#{ adapter_prefix }postgresql://127.0.0.1/#{ @database }?user=#{ POSTGRES_USER }"

      Lotus::Model.configure do
        adapter type: :sql, uri: uri
        migrations __dir__ + '/../../fixtures/migrations'
      end
    end

    after do
      SQLite3::Database.new(@uri) { |db| db.close } if File.exist?(@database)
    end

    describe "create" do
      it "creates the database" do
        Lotus::Model::Migrator.create

        connection = Sequel.connect(@uri)
        connection.tables.must_be :empty?
      end
    end

    describe "drop" do
      before do
        Lotus::Model::Migrator.create
      end

      it "drops the database" do
        Lotus::Model::Migrator.drop

        -> { Sequel.connect(@uri).tables }.must_raise Sequel::DatabaseConnectionError
      end

      it "raises error if database doesn't exist" do
        Lotus::Model::Migrator.drop # remove the first time
        exception = -> { Lotus::Model::Migrator.drop }.must_raise Lotus::Model::MigrationError
        exception.message.must_equal "Cannot find database: #{ @database }"
      end

      it 'raises error if database is busy' do
        Sequel.connect(@uri).tables
        exception = -> { Lotus::Model::Migrator.drop }.must_raise Lotus::Model::MigrationError
        exception.message.must_include 'dropdb: database removal failed'
        exception.message.must_include 'There is 1 other session using the database'
      end
    end

    describe "migrate" do
      before do
        Lotus::Model::Migrator.create
      end

      describe "when no migrations" do
        before do
          @migrations_root = migrations_root = Pathname.new(__dir__ + '/../../fixtures/empty_migrations')

          Lotus::Model.configure do
            migrations migrations_root
          end
        end

        it "it doesn't alter database" do
          Lotus::Model::Migrator.migrate

          connection = Sequel.connect(@uri)
          connection.tables.must_be :empty?
        end
      end

      describe "when migrations are present" do
        it "migrates the database" do
          Lotus::Model::Migrator.migrate

          connection = Sequel.connect(@uri)
          connection.tables.wont_be :empty?

          table = connection.schema(:books)

          name, options = table[0] # id
          name.must_equal :id

          options.fetch(:allow_null).must_equal     false
          options.fetch(:default).must_equal        "nextval('books_id_seq'::regclass)"
          options.fetch(:type).must_equal           :integer
          options.fetch(:db_type).must_equal        "integer"
          options.fetch(:primary_key).must_equal    true
          options.fetch(:auto_increment).must_equal true

          name, options = table[1] # title
          name.must_equal :title

          options.fetch(:allow_null).must_equal     false
          options.fetch(:default).must_equal        nil
          options.fetch(:type).must_equal           :string
          options.fetch(:db_type).must_equal        "text"
          options.fetch(:primary_key).must_equal    false

          name, options = table[2] # price (second migration)
          name.must_equal :price

          options.fetch(:allow_null).must_equal     true
          options.fetch(:default).must_equal        "100"
          options.fetch(:type).must_equal           :integer
          options.fetch(:db_type).must_equal        "integer"
          options.fetch(:primary_key).must_equal    false
        end
      end

      describe "when migrations are ran twice" do
        before do
          Lotus::Model::Migrator.migrate
        end

        it "doesn't alter the schema" do
          Lotus::Model::Migrator.migrate

          connection = Sequel.connect(@uri)
          connection.tables.wont_be :empty?
          connection.tables.must_equal [:schema_migrations, :books]
        end
      end

      describe "migrate down" do
        before do
          Lotus::Model::Migrator.migrate
        end

        it "migrates the database" do
          Lotus::Model::Migrator.migrate(version: '20150610133853')

          connection = Sequel.connect(@uri)
          connection.tables.wont_be :empty?

          table = connection.schema(:books)

          name, options = table[0] # id
          name.must_equal :id

          options.fetch(:allow_null).must_equal     false
          options.fetch(:default).must_equal        "nextval('books_id_seq'::regclass)"
          options.fetch(:type).must_equal           :integer
          options.fetch(:db_type).must_equal        "integer"
          options.fetch(:primary_key).must_equal    true
          options.fetch(:auto_increment).must_equal true

          name, options = table[1] # title
          name.must_equal :title

          options.fetch(:allow_null).must_equal     false
          options.fetch(:default).must_equal        nil
          options.fetch(:type).must_equal           :string
          options.fetch(:db_type).must_equal        "text"
          options.fetch(:primary_key).must_equal    false

          name, options = table[2] # price (rolled back second migration)
          name.must_be_nil
          options.must_be_nil
        end
      end
    end

    describe "apply" do
      before do
        uri              = @uri
        @migrations_root = migrations_root = Pathname.new(__dir__ + '/../../../tmp')
        @fixtures_root   = fixtures_root   = Pathname.new(__dir__ + '/../../fixtures/migrations')

        migrations_root.mkpath
        FileUtils.cp_r(fixtures_root, migrations_root)

        Lotus::Model.unload!
        Lotus::Model.configure do
          adapter type: :sql, uri: uri

          migrations migrations_root.join('migrations')
          schema     migrations_root.join('schema-postgres.sql')
        end

        Lotus::Model::Migrator.create
        Lotus::Model::Migrator.apply
      end

      it "migrates to latest version" do
        connection = Sequel.connect(@uri)
        migration  = connection[:schema_migrations].to_a[1]

        migration.fetch(:filename).must_include("20150610141017")
      end

      it "dumps database schema.sql" do
        schema = @migrations_root.join('schema-postgres.sql').read

        schema.must_include <<-SQL
CREATE TABLE books (
    id integer NOT NULL,
    title text NOT NULL,
    price integer DEFAULT 100
);
SQL

        schema.must_include <<-SQL
CREATE SEQUENCE books_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
SQL

        schema.must_include <<-SQL
ALTER SEQUENCE books_id_seq OWNED BY books.id;
SQL

        schema.must_include <<-SQL
ALTER TABLE ONLY books ALTER COLUMN id SET DEFAULT nextval('books_id_seq'::regclass);
SQL

        schema.must_include <<-SQL
ALTER TABLE ONLY books
    ADD CONSTRAINT books_pkey PRIMARY KEY (id);
SQL

        schema.must_include <<-SQL
CREATE TABLE schema_migrations (
    filename text NOT NULL
);
SQL

        schema.must_include <<-SQL
COPY schema_migrations (filename) FROM stdin;
20150610133853_create_books.rb
20150610141017_add_price_to_books.rb
SQL

        schema.must_include <<-SQL
ALTER TABLE ONLY schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (filename);
SQL
      end

      it "deletes all the migrations" do
        @migrations_root.join('migrations').children.must_be :empty?
      end
    end

    describe "prepare" do
      before do
        uri              = @uri
        @migrations_root = migrations_root = Pathname.new(__dir__ + '/../../../tmp')
        @fixtures_root   = fixtures_root   = Pathname.new(__dir__ + '/../../fixtures/migrations')

        migrations_root.mkpath
        FileUtils.cp_r(fixtures_root, migrations_root)

        Lotus::Model.unload!
        Lotus::Model.configure do
          adapter type: :sql, uri: uri

          migrations migrations_root.join('migrations')
          schema     migrations_root.join('schema-postgres.sql')
        end
      end

      it "creates database, loads schema and migrate" do
        # Simulate already existing schema.sql, without existing database and pending migrations
        connection = Sequel.connect(@uri)

        FileUtils.cp 'test/fixtures/20150611165922_create_authors.rb',
          @migrations_root.join('migrations/20150611165922_create_authors.rb')

        Lotus::Model::Migrator.prepare

        connection.tables.must_include(:schema_migrations)
        connection.tables.must_include(:books)
        connection.tables.must_include(:authors)

        FileUtils.rm_f @migrations_root.join('migrations/20150611165922_create_authors.rb')
      end

      it "works even if schema doesn't exist" do
        # Simulate no database, no schema and pending migrations
        @migrations_root.join('migrations/20150611165922_create_authors.rb').delete rescue nil
        @migrations_root.join('schema-postgres.sql').delete                         rescue nil

        Lotus::Model::Migrator.prepare

        connection = Sequel.connect(@uri)
        connection.tables.must_equal [:schema_migrations, :books]
      end

      it "drops the database and recreate it" do
        Lotus::Model::Migrator.create
        Lotus::Model::Migrator.prepare

        connection = Sequel.connect(@uri)
        connection.tables.must_include(:schema_migrations)
        connection.tables.must_include(:books)
      end
    end

    describe "version" do
      before do
        Lotus::Model::Migrator.create
      end

      describe "when no migrations were ran" do
        it "returns nil" do
          version = Lotus::Model::Migrator.version
          version.must_be_nil
        end
      end

      describe "with migrations" do
        before do
          Lotus::Model::Migrator.migrate
        end

        it "returns current database version" do
          version = Lotus::Model::Migrator.version
          version.must_equal "20150610141017"
        end
      end
    end
  end
end
