require 'test_helper'
require 'hanami/model/migrator'

describe "Hanami::Model.migration" do
  let(:adapter_prefix) { 'jdbc:' if Hanami::Utils.jruby?  }

  describe "SQLite" do
    before do
      @database = Pathname.new("#{ __dir__ }/../../tmp/migration.sqlite3").expand_path
      @schema   = schema_path = Pathname.new("#{ __dir__ }/../../tmp/schema.sql").expand_path
      @uri      = uri = "#{ adapter_prefix }sqlite://#{ @database }"

      Hanami::Model.configure do
        adapter type: :sql, uri: uri
        migrations __dir__ + '/../fixtures/database_migrations'
        schema     schema_path
      end

      Hanami::Model::Migrator.create
      Hanami::Model::Migrator.migrate

      @connection = Sequel.connect(@uri)
      Hanami::Model::Migrator::Adapter.for(@connection).dump
    end

    after(:each) do
      File.delete(@database)
      File.delete(@schema)
    end

    after(:each) do
      Hanami::Model.unload!
      @connection.disconnect
    end

    describe "columns" do
      it "defines column types" do
        table = @connection.schema(:column_types)

        name, options = table[0]
        name.must_equal :integer1

        options.fetch(:allow_null).must_equal  true
        options.fetch(:default).must_equal     nil
        options.fetch(:type).must_equal        :integer
        options.fetch(:db_type).must_equal     "integer"
        options.fetch(:primary_key).must_equal false

        name, options = table[1]
        name.must_equal :integer2

        options.fetch(:allow_null).must_equal  true
        options.fetch(:default).must_equal     nil
        options.fetch(:type).must_equal        :integer
        options.fetch(:db_type).must_equal     "integer"
        options.fetch(:primary_key).must_equal false

        name, options = table[2]
        name.must_equal :integer3

        options.fetch(:allow_null).must_equal  true
        options.fetch(:default).must_equal     nil
        options.fetch(:type).must_equal        :integer
        options.fetch(:db_type).must_equal     "integer"
        options.fetch(:primary_key).must_equal false

        name, options = table[3]
        name.must_equal :string1

        options.fetch(:allow_null).must_equal  true
        options.fetch(:default).must_equal     nil
        options.fetch(:type).must_equal        :string
        options.fetch(:db_type).must_equal     "varchar(255)"
        options.fetch(:primary_key).must_equal false

        name, options = table[4]
        name.must_equal :string2

        options.fetch(:allow_null).must_equal  true
        options.fetch(:default).must_equal     nil
        options.fetch(:type).must_equal        :string
        options.fetch(:db_type).must_equal     "string"
        options.fetch(:primary_key).must_equal false

        name, options = table[5]
        name.must_equal :string3

        options.fetch(:allow_null).must_equal  true
        options.fetch(:default).must_equal     nil
        options.fetch(:type).must_equal        :string
        options.fetch(:db_type).must_equal     "string"
        options.fetch(:primary_key).must_equal false

        name, options = table[6]
        name.must_equal :string4

        options.fetch(:allow_null).must_equal  true
        options.fetch(:default).must_equal     nil
        options.fetch(:type).must_equal        :string
        options.fetch(:db_type).must_equal     "varchar(3)"
        options.fetch(:primary_key).must_equal false

        name, options = table[7]
        name.must_equal :string5

        options.fetch(:allow_null).must_equal  true
        options.fetch(:default).must_equal     nil
        options.fetch(:type).must_equal        :string
        options.fetch(:db_type).must_equal     "varchar(50)"
        options.fetch(:max_length).must_equal  50
        options.fetch(:primary_key).must_equal false

        name, options = table[8]
        name.must_equal :string6

        options.fetch(:allow_null).must_equal  true
        options.fetch(:default).must_equal     nil
        options.fetch(:type).must_equal        :string
        options.fetch(:db_type).must_equal     "char(255)"
        options.fetch(:primary_key).must_equal false

        name, options = table[9]
        name.must_equal :string7

        options.fetch(:allow_null).must_equal  true
        options.fetch(:default).must_equal     nil
        options.fetch(:type).must_equal        :string
        options.fetch(:db_type).must_equal     "char(64)"
        options.fetch(:max_length).must_equal  64
        options.fetch(:primary_key).must_equal false

        name, options = table[10]
        name.must_equal :string8

        options.fetch(:allow_null).must_equal  true
        options.fetch(:default).must_equal     nil
        options.fetch(:type).must_equal        :string
        options.fetch(:db_type).must_equal     "text"
        options.fetch(:primary_key).must_equal false

        name, options = table[11]
        name.must_equal :file1

        options.fetch(:allow_null).must_equal  true
        options.fetch(:default).must_equal     nil
        options.fetch(:type).must_equal        :blob
        options.fetch(:db_type).must_equal     "blob"
        options.fetch(:primary_key).must_equal false

        name, options = table[12]
        name.must_equal :file2

        options.fetch(:allow_null).must_equal  true
        options.fetch(:default).must_equal     nil
        options.fetch(:type).must_equal        :blob
        options.fetch(:db_type).must_equal     "blob"
        options.fetch(:primary_key).must_equal false

        name, options = table[13]
        name.must_equal :number1

        options.fetch(:allow_null).must_equal  true
        options.fetch(:default).must_equal     nil
        options.fetch(:type).must_equal        :integer
        options.fetch(:db_type).must_equal     "integer"
        options.fetch(:primary_key).must_equal false

        name, options = table[14]
        name.must_equal :number2

        options.fetch(:allow_null).must_equal  true
        options.fetch(:default).must_equal     nil
        options.fetch(:type).must_equal        :integer
        options.fetch(:db_type).must_equal     "bigint"
        options.fetch(:primary_key).must_equal false

        name, options = table[15]
        name.must_equal :number3

        options.fetch(:allow_null).must_equal  true
        options.fetch(:default).must_equal     nil
        options.fetch(:type).must_equal        :float
        options.fetch(:db_type).must_equal     "double precision"
        options.fetch(:primary_key).must_equal false

        name, options = table[16]
        name.must_equal :number4

        options.fetch(:allow_null).must_equal  true
        options.fetch(:default).must_equal     nil
        options.fetch(:type).must_equal        :decimal
        options.fetch(:db_type).must_equal     "numeric"
        options.fetch(:primary_key).must_equal false

        name, options = table[17]
        name.must_equal :number5

        options.fetch(:allow_null).must_equal  true
        options.fetch(:default).must_equal     nil
        # options.fetch(:type).must_equal        :decimal
        options.fetch(:db_type).must_equal     "numeric(10)"
        options.fetch(:primary_key).must_equal false

        name, options = table[18]
        name.must_equal :number6

        options.fetch(:allow_null).must_equal  true
        options.fetch(:default).must_equal     nil
        options.fetch(:type).must_equal        :decimal
        options.fetch(:db_type).must_equal     "numeric(10, 2)"
        options.fetch(:primary_key).must_equal false

        name, options = table[19]
        name.must_equal :number7

        options.fetch(:allow_null).must_equal  true
        options.fetch(:default).must_equal     nil
        options.fetch(:type).must_equal        :decimal
        options.fetch(:db_type).must_equal     "numeric"
        options.fetch(:primary_key).must_equal false

        name, options = table[20]
        name.must_equal :date1

        options.fetch(:allow_null).must_equal  true
        options.fetch(:default).must_equal     nil
        options.fetch(:type).must_equal        :date
        options.fetch(:db_type).must_equal     "date"
        options.fetch(:primary_key).must_equal false

        name, options = table[21]
        name.must_equal :date2

        options.fetch(:allow_null).must_equal  true
        options.fetch(:default).must_equal     nil
        options.fetch(:type).must_equal        :datetime
        options.fetch(:db_type).must_equal     "timestamp"
        options.fetch(:primary_key).must_equal false

        name, options = table[22]
        name.must_equal :time1

        options.fetch(:allow_null).must_equal  true
        options.fetch(:default).must_equal     nil
        options.fetch(:type).must_equal        :datetime
        options.fetch(:db_type).must_equal     "timestamp"
        options.fetch(:primary_key).must_equal false

        name, options = table[23]
        name.must_equal :time2

        options.fetch(:allow_null).must_equal  true
        options.fetch(:default).must_equal     nil
        options.fetch(:type).must_equal        :time
        options.fetch(:db_type).must_equal     "time"
        options.fetch(:primary_key).must_equal false

        name, options = table[24]
        name.must_equal :boolean1

        options.fetch(:allow_null).must_equal  true
        options.fetch(:default).must_equal     nil
        options.fetch(:type).must_equal        :boolean
        options.fetch(:db_type).must_equal     "boolean"
        options.fetch(:primary_key).must_equal false

        name, options = table[25]
        name.must_equal :boolean2

        options.fetch(:allow_null).must_equal  true
        options.fetch(:default).must_equal     nil
        options.fetch(:type).must_equal        :boolean
        options.fetch(:db_type).must_equal     "boolean"
        options.fetch(:primary_key).must_equal false
      end

      it "defines column defaults" do
        table = @connection.schema(:default_values)

        name, options = table[0]
        name.must_equal :a

        options.fetch(:allow_null).must_equal  true
        options.fetch(:default).must_equal     "23"
        options.fetch(:ruby_default).must_equal 23
        options.fetch(:type).must_equal        :integer
        options.fetch(:db_type).must_equal     "integer"
        options.fetch(:primary_key).must_equal false

        name, options = table[1]
        name.must_equal :b

        options.fetch(:allow_null).must_equal  true
        options.fetch(:default).must_equal     "'Hanami'"
        options.fetch(:ruby_default).must_equal "Hanami"
        options.fetch(:type).must_equal        :string
        options.fetch(:db_type).must_equal     "varchar(255)"
        options.fetch(:primary_key).must_equal false

        name, options = table[2]
        name.must_equal :c

        options.fetch(:allow_null).must_equal  true
        options.fetch(:default).must_equal     "-1"
        options.fetch(:ruby_default).must_equal(-1)
        options.fetch(:type).must_equal        :integer
        options.fetch(:db_type).must_equal     "integer"
        options.fetch(:primary_key).must_equal false

        name, options = table[3]
        name.must_equal :d

        options.fetch(:allow_null).must_equal  true
        options.fetch(:default).must_equal     "0"
        options.fetch(:ruby_default).must_equal 0
        options.fetch(:type).must_equal        :integer
        options.fetch(:db_type).must_equal     "bigint"
        options.fetch(:primary_key).must_equal false

        name, options = table[4]
        name.must_equal :e

        options.fetch(:allow_null).must_equal  true
        options.fetch(:default).must_equal     "3.14"
        options.fetch(:ruby_default).must_equal 3.14
        options.fetch(:type).must_equal        :float
        options.fetch(:db_type).must_equal     "double precision"
        options.fetch(:primary_key).must_equal false

        name, options = table[5]
        name.must_equal :f

        options.fetch(:allow_null).must_equal  true
        options.fetch(:default).must_equal     "1.0"
        options.fetch(:ruby_default).must_equal 1.0
        options.fetch(:type).must_equal        :decimal
        options.fetch(:db_type).must_equal     "numeric"
        options.fetch(:primary_key).must_equal false

        name, options = table[6]
        name.must_equal :g

        options.fetch(:allow_null).must_equal  true
        options.fetch(:default).must_equal     "943943"
        options.fetch(:ruby_default).must_equal 943943
        options.fetch(:type).must_equal        :decimal
        options.fetch(:db_type).must_equal     "numeric"
        options.fetch(:primary_key).must_equal false

        name, options = table[10]
        name.must_equal :k

        options.fetch(:allow_null).must_equal  true
        options.fetch(:default).must_equal     "1"
        options.fetch(:ruby_default).must_equal true
        options.fetch(:type).must_equal        :boolean
        options.fetch(:db_type).must_equal     "boolean"
        options.fetch(:primary_key).must_equal false

        name, options = table[11]
        name.must_equal :l

        options.fetch(:allow_null).must_equal  true
        options.fetch(:default).must_equal     "0"
        options.fetch(:ruby_default).must_equal false
        options.fetch(:type).must_equal        :boolean
        options.fetch(:db_type).must_equal     "boolean"
        options.fetch(:primary_key).must_equal false
      end

      it "defines null constraint" do
        table = @connection.schema(:null_constraints)

        name, options = table[0]
        name.must_equal :a

        options.fetch(:allow_null).must_equal true

        name, options = table[1]
        name.must_equal :b

        options.fetch(:allow_null).must_equal false

        name, options = table[2]
        name.must_equal :c

        options.fetch(:allow_null).must_equal true
      end

      it "defines column index" do
        indexes = @connection.indexes(:column_indexes)

        indexes.fetch(:column_indexes_a_index, nil).must_be_nil
        indexes.fetch(:column_indexes_b_index, nil).must_be_nil

        index = indexes.fetch(:column_indexes_c_index)
        index[:unique].must_equal false
        index[:columns].must_equal [:c]
      end

      it "defines index via #index" do
        indexes = @connection.indexes(:column_indexes)

        index = indexes.fetch(:column_indexes_d_index)
        index[:unique].must_equal true
        index[:columns].must_equal [:d]

        index = indexes.fetch(:column_indexes_b_c_index)
        index[:unique].must_equal false
        index[:columns].must_equal [:b, :c]

        index = indexes.fetch(:column_indexes_coords_index)
        index[:unique].must_equal false
        index[:columns].must_equal [:lat, :lng]
      end

      it "defines primary key (via #primary_key :id)" do
        table = @connection.schema(:primary_keys_1)

        name, options = table[0]
        name.must_equal :id

        options.fetch(:allow_null).must_equal     false
        options.fetch(:default).must_equal        nil
        options.fetch(:type).must_equal           :integer
        options.fetch(:db_type).must_equal        "integer"
        options.fetch(:primary_key).must_equal    true
        options.fetch(:auto_increment).must_equal true
      end

      it "defines composite primary key (via #primary_key [:column1, :column2])" do
        table = @connection.schema(:primary_keys_3)

        name, options = table[0]
        name.must_equal :group_id

        options.fetch(:allow_null).must_equal     true
        options.fetch(:default).must_equal        nil
        options.fetch(:type).must_equal           :integer
        options.fetch(:db_type).must_equal        "integer"
        options.fetch(:primary_key).must_equal    true
        options.fetch(:auto_increment).must_equal true

        name, options = table[1]
        name.must_equal :position

        options.fetch(:allow_null).must_equal     true
        options.fetch(:default).must_equal        nil
        options.fetch(:type).must_equal           :integer
        options.fetch(:db_type).must_equal        "integer"
        options.fetch(:primary_key).must_equal    true
        options.fetch(:auto_increment).must_equal true
      end

      it "defines primary key (via #column primary_key: true)" do
        table = @connection.schema(:primary_keys_2)

        name, options = table[0]
        name.must_equal :name

        options.fetch(:allow_null).must_equal     false
        options.fetch(:default).must_equal        nil
        options.fetch(:type).must_equal           :string
        options.fetch(:db_type).must_equal        "varchar(255)"
        options.fetch(:primary_key).must_equal    true
        options.fetch(:auto_increment).must_equal false
      end

      it "defines foreign key (via #foreign_key)" do
        table = @connection.schema(:albums)

        name, options = table[1]
        name.must_equal :artist_id

        options.fetch(:allow_null).must_equal     false
        options.fetch(:default).must_equal        nil
        options.fetch(:type).must_equal           :integer
        options.fetch(:db_type).must_equal        "integer"
        options.fetch(:primary_key).must_equal    false

        foreign_key = @connection.foreign_key_list(:albums).first
        foreign_key.fetch(:columns).must_equal   [:artist_id]
        foreign_key.fetch(:table).must_equal     :artists
        foreign_key.fetch(:key).must_equal       nil
        foreign_key.fetch(:on_update).must_equal :no_action
        foreign_key.fetch(:on_delete).must_equal :cascade
      end

      it "defines column constraint and check" do
        @schema.read.must_include %(CREATE TABLE `table_constraints` (`age` integer, `role` varchar(255), CONSTRAINT `age_constraint` CHECK (`age` > 18), CHECK (role IN("contributor", "manager", "owner")));)
      end
    end
  end

  describe "File system" do
    before do
      Hanami::Model.configure do
        adapter type: :file_system, uri: "file:///db/test417_development"
      end
    end

    describe "connection" do
      it "return error" do
        exception = -> { Hanami::Model::Migrator.create }.must_raise Hanami::Model::MigrationError
        exception.message.must_include "Current adapter (file_system) doesn't support SQL database operations."
      end
    end
  end

  describe "Memory" do
    before do
      Hanami::Model.configure do
        adapter type: :memory, uri: "memory://localhost"
      end
    end

    describe "connection" do
      it "return error" do
        exception = -> { Hanami::Model::Migrator.create }.must_raise Hanami::Model::MigrationError
        exception.message.must_include "Current adapter (memory) doesn't support SQL database operations."
      end
    end
  end
end
