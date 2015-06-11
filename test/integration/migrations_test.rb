require 'test_helper'
require 'lotus/model/migrator'

describe "Database migrations" do
  before do
    Lotus::Model.unload!
  end

  after do
    Lotus::Model::Migrator.drop rescue nil
    Lotus::Model.unload!
  end

  describe "SQLite (memory)" do
    before do
      @uri = uri = "sqlite:/"

      Lotus::Model.configure do
        adapter type: :sql, uri: uri
        migrations __dir__ + '/../fixtures/migrations'
      end
    end

    describe "create" do
      it "does nothing" do
        Lotus::Model::Migrator.create

        connection = Sequel.connect(@uri)
        connection.tables.must_be :empty?
      end
    end

    describe "drop" do
      before do
        Lotus::Model::Migrator.create
      end

      it "does nothing" do
        Lotus::Model::Migrator.drop

        connection = Sequel.connect(@uri)
        connection.tables.must_be :empty?
      end
    end

    describe "migrate" do
      before do
        Lotus::Model::Migrator.create
      end

      describe "when no migrations" do
        before do
          Lotus::Model.configure do
            migrations __dir__ + '/../../tmp'
          end

          Lotus::Model::Migrator.create
        end

        it "it raises error" do
          -> { Lotus::Model::Migrator.migrate }.must_raise Lotus::Model::MigrationError
        end
      end
    end
  end

  describe "SQLite (filesystem)" do
    before do
      @database = Pathname.new("#{ __dir__ }/../../tmp/create-#{ SecureRandom.hex }.sqlite3").expand_path
      @uri      = uri = "sqlite://#{ @database }"

      Lotus::Model.configure do
        adapter type: :sql, uri: uri
        migrations __dir__ + '/../fixtures/migrations'
      end
    end

    describe "create" do
      it "creates the database" do
        Lotus::Model::Migrator.create
        assert File.exist?(@database), "Expected database #{ @database } to exist"
      end

      describe "when it doesn't have write permissions" do
        before do
          Lotus::Model.unload!
          Lotus::Model.configure do
            adapter type: :sql, uri: 'sqlite:///usr/bin/create.sqlite3'
          end
        end

        it "raises an error" do
          exception = -> { Lotus::Model::Migrator.create }.must_raise Lotus::Model::MigrationError
          exception.message.must_equal "Permission denied: /usr/bin/create.sqlite3"
        end
      end
    end

    describe "drop" do
      before do
        Lotus::Model::Migrator.create
      end

      it "drops the database" do
        Lotus::Model::Migrator.drop
        assert !File.exist?(@database), "Expected database #{ @database } to NOT exist"
      end

      it "raises error if database doesn't exist" do
        Lotus::Model::Migrator.drop # remove the first time

        exception = -> { Lotus::Model::Migrator.drop }.must_raise Lotus::Model::MigrationError
        exception.message.must_equal "Cannot find database: #{ @database }"
      end
    end

    describe "migrate" do
      before do
        Lotus::Model::Migrator.create
      end

      describe "when no migrations" do
        before do
          Lotus::Model.configure do
            migrations __dir__ + '/../../tmp'
          end

          Lotus::Model::Migrator.create
        end

        it "it raises error" do
          -> { Lotus::Model::Migrator.migrate }.must_raise Lotus::Model::MigrationError
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
          Lotus::Model::Migrator.migrate
        end

        it "doesn't alter the schema" do
          Lotus::Model::Migrator.migrate

          connection = Sequel.connect(@uri)
          connection.tables.wont_be :empty?
          connection.tables.must_equal [:schema_migrations, :books]
        end
      end
    end
  end

  describe "PostgreSQL" do
    before do
      @database  = "migrations-#{ SecureRandom.hex }"
      @uri = uri = "postgres://localhost/#{ @database }?user=#{ POSTGRES_USER }"

      Lotus::Model.configure do
        adapter type: :sql, uri: uri
        migrations __dir__ + '/../fixtures/migrations'
      end
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
    end

    describe "migrate" do
      before do
        Lotus::Model::Migrator.create
      end

      describe "when no migrations" do
        before do
          Lotus::Model.configure do
            migrations __dir__ + '/../../tmp'
          end
        end

        it "it raises error" do
          -> { Lotus::Model::Migrator.migrate }.must_raise Lotus::Model::MigrationError
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
    end
  end

  describe "MySQL" do
    before do
      @database  = "migrations#{ SecureRandom.hex }"
      @uri = uri = "mysql2://#{ MYSQL_USER }@localhost/#{ @database }"

      Lotus::Model.configure do
        adapter type: :sql, uri: uri
        migrations __dir__ + '/../fixtures/migrations'
      end
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
    end

    describe "migrate" do
      before do
        Lotus::Model::Migrator.create
      end

      describe "when no migrations" do
        before do
          Lotus::Model.configure do
            migrations __dir__ + '/../../tmp'
          end
        end

        it "it raises error" do
          -> { Lotus::Model::Migrator.migrate }.must_raise Lotus::Model::MigrationError
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
          options.fetch(:default).must_equal        nil
          options.fetch(:type).must_equal           :integer
          options.fetch(:db_type).must_equal        "int(11)"
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
          options.fetch(:db_type).must_equal        "int(11)"
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
          connection.tables.must_equal [:books, :schema_migrations]
        end
      end
    end
  end
end
