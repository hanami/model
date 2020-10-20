# frozen_string_literal: true
Hanami::Model.migration do
  change do
    case Database.engine
    when :sqlite
      create_table :column_types do
        column :integer1, Integer
        column :integer2, :integer
        column :integer3, "integer"

        column :string1, String
        column :string2, :string
        column :string3, "string"
        column :string4, "varchar(3)"

        column :string5, String, size: 50
        column :string6, String, fixed: true
        column :string7, String, fixed: true, size: 64
        column :string8, String, text: true

        column :file1, File
        column :file2, "blob"

        column :number1, Fixnum # rubocop:disable Lint/UnifiedInteger
        column :number2, :Bignum
        column :number3, Float
        column :number4, BigDecimal
        column :number5, BigDecimal, size: 10
        column :number6, BigDecimal, size: [10, 2]
        column :number7, Numeric

        column :date1, Date
        column :date2, DateTime

        column :time1, Time
        column :time2, Time, only_time: true

        column :boolean1, TrueClass
        column :boolean2, FalseClass
      end
    when :postgresql
      execute 'CREATE EXTENSION IF NOT EXISTS "uuid-ossp"'
      execute "CREATE TYPE mood AS ENUM ('sad', 'ok', 'happy');"
      execute %{
        CREATE TYPE inventory_item AS (
          name            text,
          supplier_id     integer,
          price           numeric
        );
      }

      create_table :column_types do
        column :integer1, Integer
        column :integer2, :integer
        column :integer3, "integer"

        column :string1, String
        column :string2, "text"
        column :string3, "character varying(1)"
        column :string4, "varchar(2)"
        column :string5, "character(3)"
        column :string6, "char(4)"

        column :string7, String, size: 50
        column :string8, String, fixed: true
        column :string9, String, fixed: true, size: 64
        column :string10, String, text: true

        column :file1, File
        column :file2, "bytea"

        column :number1, Fixnum # rubocop:disable Lint/UnifiedInteger
        column :number2, :Bignum
        column :number3, Float
        column :number4, BigDecimal
        column :number5, BigDecimal, size: 10
        column :number6, BigDecimal, size: [10, 2]
        column :number7, Numeric

        column :date1, Date
        column :date2, DateTime

        column :time1, Time
        column :time2, Time, only_time: true

        column :boolean1, TrueClass
        column :boolean2, FalseClass

        column :array1, "integer[]"
        column :array2, "integer[3]"
        column :array3, "text[][]"

        column :money1, "money"

        column :enum1, "mood"

        column :geometric1, "point"
        column :geometric2, "line"
        column :geometric3, "circle", default: "<(15,15), 1>"

        column :net1, "cidr", default: "192.168/24"

        column :uuid1, "uuid", default: Hanami::Model::Sql.function(:uuid_generate_v4)

        column :xml1, "xml"

        column :json1, "json"
        column :json2, "jsonb"

        column :composite1, "inventory_item", default: Hanami::Model::Sql.literal("ROW('fuzzy dice', 42, 1.99)")
      end
    when :mysql
      create_table :column_types do
        column :integer1, Integer
        column :integer2, :integer
        column :integer3, "integer"

        column :string1, String
        column :string2, "varchar(3)"

        column :string5, String, size: 50
        column :string6, String, fixed: true
        column :string7, String, fixed: true, size: 64
        column :string8, String, text: true

        column :file1, File
        column :file2, "blob"

        column :number1, Fixnum # rubocop:disable Lint/UnifiedInteger
        column :number2, :Bignum
        column :number3, Float
        column :number4, BigDecimal
        column :number5, BigDecimal, size: 10
        column :number6, BigDecimal, size: [10, 2]
        column :number7, Numeric

        column :date1, Date
        column :date2, DateTime

        column :time1, Time
        column :time2, Time, only_time: true

        column :boolean1, TrueClass
        column :boolean2, FalseClass
      end
    end
  end
end
