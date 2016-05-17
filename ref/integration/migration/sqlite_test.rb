require 'test_helper'
require 'hanami/model/migrator'

describe 'Filesystem SQLite Database migrations' do
  let(:adapter_prefix) { 'jdbc:' if Hanami::Utils.jruby?  }

  before do
    Hanami::Model.unload!
  end

  after do
    Hanami::Model::Migrator.drop rescue nil
    Hanami::Model.unload!
  end

  describe "SQLite filesystem" do
    before do
      @database = Pathname.new("#{ __dir__ }/../../../tmp/create-#{ SecureRandom.hex }.sqlite3").expand_path
      @uri      = uri = "#{ adapter_prefix }sqlite://#{ @database }"

      Hanami::Model.configure do
        adapter type: :sql, uri: uri
        migrations __dir__ + '/../../fixtures/migrations'
      end
    end

    describe "create" do
      it "creates the database" do
        Hanami::Model::Migrator.create
        assert File.exist?(@database), "Expected database #{ @database } to exist"
      end

      describe "when it doesn't have write permissions" do
        before do
          @database = '/usr/bin/create.sqlite3'
          @uri      = uri = "#{ adapter_prefix }sqlite://#{ @database }"

          Hanami::Model.unload!
          Hanami::Model.configure do
            adapter type: :sql, uri: uri
          end
        end

        it "raises an error" do
          exception = -> { Hanami::Model::Migrator.create }.must_raise Hanami::Model::MigrationError
          exception.message.must_equal "Permission denied: /usr/bin/create.sqlite3"
        end
      end
    end

    describe "drop" do
      before do
        Hanami::Model::Migrator.create
      end

      it "drops the database" do
        Hanami::Model::Migrator.drop
        assert !File.exist?(@database), "Expected database #{ @database } to NOT exist"
      end

      it "raises error if database doesn't exist" do
        Hanami::Model::Migrator.drop # remove the first time

        exception = -> { Hanami::Model::Migrator.drop }.must_raise Hanami::Model::MigrationError
        exception.message.must_equal "Cannot find database: #{ @database }"
      end
    end

    describe "migrate" do
      before do
        Hanami::Model::Migrator.create
      end

      describe "when no migrations" do
        before do
          @migrations_root = migrations_root = Pathname.new(__dir__ + '/../../fixtures/empty_migrations')

          Hanami::Model.configure do
            migrations migrations_root
          end

          Hanami::Model::Migrator.create
        end

        it "it doesn't alter database" do
          Hanami::Model::Migrator.migrate

          connection = Sequel.connect(@uri)
          connection.tables.must_be :empty?
        end
      end

      describe "when migrations are present" do
        it "migrates the database" do
          Hanami::Model::Migrator.migrate

          connection = Sequel.connect(@uri)
          connection.tables.wont_be :empty?

          table = connection.schema(:books)

          name, options = table[0] # id
          name.must_equal :id

          options.fetch(:allow_null).must_equal     false
          options.fetch(:default).must_equal        nil
          options.fetch(:type).must_equal           :integer
          options.fetch(:db_type).must_equal        "integer"
          options.fetch(:primary_key).must_equal    true
          options.fetch(:auto_increment).must_equal true

          name, options = table[1] # title
          name.must_equal :title

          options.fetch(:allow_null).must_equal     false
          options.fetch(:default).must_equal        nil
          options.fetch(:type).must_equal           :string
          options.fetch(:db_type).must_equal        "varchar(255)"
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
          Hanami::Model::Migrator.migrate
        end

        it "doesn't alter the schema" do
          Hanami::Model::Migrator.migrate

          connection = Sequel.connect(@uri)
          connection.tables.wont_be :empty?
          connection.tables.must_equal [:schema_migrations, :books]
        end
      end

      describe "migrate down" do
        before do
          Hanami::Model::Migrator.migrate
        end

        it "migrates the database" do
          Hanami::Model::Migrator.migrate(version: '20150610133853')

          connection = Sequel.connect(@uri)
          connection.tables.wont_be :empty?

          table = connection.schema(:books)

          name, options = table[0] # id
          name.must_equal :id

          options.fetch(:allow_null).must_equal     false
          options.fetch(:default).must_equal        nil
          options.fetch(:type).must_equal           :integer
          options.fetch(:db_type).must_equal        "integer"
          options.fetch(:primary_key).must_equal    true
          options.fetch(:auto_increment).must_equal true

          name, options = table[1] # title
          name.must_equal :title

          options.fetch(:allow_null).must_equal     false
          options.fetch(:default).must_equal        nil
          options.fetch(:type).must_equal           :string
          options.fetch(:db_type).must_equal        "varchar(255)"
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

        Hanami::Model.unload!
        Hanami::Model.configure do
          adapter type: :sql, uri: uri

          migrations migrations_root.join('migrations')
          schema     migrations_root.join('schema-sqlite.sql')
        end

        Hanami::Model::Migrator.apply
      end

      after do
        Hanami::Model.unload!
      end

      it "migrates to latest version" do
        connection = Sequel.connect(@uri)
        migration  = connection[:schema_migrations].to_a.last

        migration.fetch(:filename).must_include("20150610141017")
      end

      it "dumps database schema.sql" do
        schema = @migrations_root.join('schema-sqlite.sql').read

        schema.must_include %(CREATE TABLE `schema_migrations` (`filename` varchar(255) NOT NULL PRIMARY KEY);)
        schema.must_include %(CREATE TABLE `books` (`id` integer NOT NULL PRIMARY KEY AUTOINCREMENT, `title` varchar(255) NOT NULL, `price` integer DEFAULT (100));)
        schema.must_include %(INSERT INTO "schema_migrations" VALUES('20150610133853_create_books.rb');)
        schema.must_include %(INSERT INTO "schema_migrations" VALUES('20150610141017_add_price_to_books.rb');)
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

        Hanami::Model.unload!
        Hanami::Model.configure do
          adapter type: :sql, uri: uri

          migrations migrations_root.join('migrations')
          schema     migrations_root.join('schema-sqlite.sql')
        end
      end

      it "creates database, loads schema and migrate" do
        # Simulate already existing schema.sql, without existing database and pending migrations
        connection = Sequel.connect(@uri)
        Hanami::Model::Migrator::Adapter.for(connection).dump

        FileUtils.cp 'test/fixtures/20150611165922_create_authors.rb',
          @migrations_root.join('migrations/20150611165922_create_authors.rb')

        Hanami::Model::Migrator.prepare

        connection.tables.must_equal [:schema_migrations, :books, :authors]

        FileUtils.rm_f @migrations_root.join('migrations/20150611165922_create_authors.rb')
      end

      it "works even if schema doesn't exist" do
        # Simulate no database, no schema and pending migrations
        FileUtils.rm_f @migrations_root.join('schema-sqlite.sql')
        Hanami::Model::Migrator.prepare

        connection = Sequel.connect(@uri)
        connection.tables.must_equal [:schema_migrations, :books]
      end

      it "drops the database and recreate it" do
        Hanami::Model::Migrator.create
        Hanami::Model::Migrator.prepare

        connection = Sequel.connect(@uri)
        connection.tables.must_include(:schema_migrations)
        connection.tables.must_include(:books)
      end
    end

    describe "version" do
      before do
        Hanami::Model::Migrator.create
      end

      describe "when no migrations were ran" do
        it "returns nil" do
          version = Hanami::Model::Migrator.version
          version.must_be_nil
        end
      end

      describe "with migrations" do
        before do
          Hanami::Model::Migrator.migrate
        end

        it "returns current database version" do
          version = Hanami::Model::Migrator.version
          version.must_equal "20150610141017"
        end
      end
    end
  end
end
