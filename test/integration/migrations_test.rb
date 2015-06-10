require 'test_helper'
require 'lotus/model/migrator'

describe "Database migrations" do
  before do
    Lotus::Model.unload!
  end

  describe "SQLite" do
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

          table = connection.schema(:users)

          name, options = table[0] # id
          name.must_equal :id

          options.fetch(:allow_null).must_equal     false
          options.fetch(:default).must_equal        nil
          options.fetch(:type).must_equal           :integer
          options.fetch(:db_type).must_equal        "integer"
          options.fetch(:primary_key).must_equal    true
          options.fetch(:auto_increment).must_equal true

          name, options = table[1] # name
          name.must_equal :name

          options.fetch(:allow_null).must_equal     false
          options.fetch(:default).must_equal        nil
          options.fetch(:type).must_equal           :string
          options.fetch(:db_type).must_equal        "string"
          options.fetch(:primary_key).must_equal    false

          name, options = table[2] # age (second migration)
          name.must_equal :age

          options.fetch(:allow_null).must_equal     true
          options.fetch(:default).must_equal        "18"
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
          connection.tables.must_equal [:schema_migrations, :users]
        end
      end
    end
  end
end
