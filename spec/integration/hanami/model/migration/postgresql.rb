# frozen_string_literal: true

RSpec.shared_examples "migration_integration_postgresql" do
  before do
    @schema = Pathname.new("#{__dir__}/../../../../../tmp/schema.sql").expand_path
    @connection = Sequel.connect(ENV["HANAMI_DATABASE_URL"])

    Hanami::Model::Migrator::Adapter.for(Hanami::Model.configuration).dump
  end

  describe "columns" do
    it "defines column types" do
      table = @connection.schema(:column_types)

      name, options = table[0]
      expect(name).to eq(:integer1)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:integer)
      expect(options.fetch(:db_type)).to eq("integer")
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[1]
      expect(name).to eq(:integer2)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:integer)
      expect(options.fetch(:db_type)).to eq("integer")
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[2]
      expect(name).to eq(:integer3)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:integer)
      expect(options.fetch(:db_type)).to eq("integer")
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[3]
      expect(name).to eq(:string1)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:string)
      expect(options.fetch(:db_type)).to eq("text")
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[4]
      expect(name).to eq(:string2)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:string)
      expect(options.fetch(:db_type)).to eq("text")
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[5]
      expect(name).to eq(:string3)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:string)
      expect(options.fetch(:db_type)).to eq("character varying(1)")
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[6]
      expect(name).to eq(:string4)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:string)
      expect(options.fetch(:db_type)).to eq("character varying(2)")
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[7]
      expect(name).to eq(:string5)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:string)
      expect(options.fetch(:db_type)).to eq("character(3)")
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[8]
      expect(name).to eq(:string6)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:string)
      expect(options.fetch(:db_type)).to eq("character(4)")
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[9]
      expect(name).to eq(:string7)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:string)
      expect(options.fetch(:db_type)).to eq("character varying(50)")
      expect(options.fetch(:max_length)).to eq(50)
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[10]
      expect(name).to eq(:string8)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:string)
      expect(options.fetch(:db_type)).to eq("character(255)")
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[11]
      expect(name).to eq(:string9)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:string)
      expect(options.fetch(:db_type)).to eq("character(64)")
      expect(options.fetch(:max_length)).to eq(64)
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[12]
      expect(name).to eq(:string10)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:string)
      expect(options.fetch(:db_type)).to eq("text")
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[13]
      expect(name).to eq(:file1)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:blob)
      expect(options.fetch(:db_type)).to eq("bytea")
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[14]
      expect(name).to eq(:file2)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:blob)
      expect(options.fetch(:db_type)).to eq("bytea")
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[15]
      expect(name).to eq(:number1)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:integer)
      expect(options.fetch(:db_type)).to eq("integer")
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[16]
      expect(name).to eq(:number2)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:integer)
      expect(options.fetch(:db_type)).to eq("bigint")
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[17]
      expect(name).to eq(:number3)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:float)
      expect(options.fetch(:db_type)).to eq("double precision")
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[18]
      expect(name).to eq(:number4)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:decimal)
      expect(options.fetch(:db_type)).to eq("numeric")
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[19]
      expect(name).to eq(:number5)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      # expect(options.fetch(:type)).to eq(:decimal)
      expect(options.fetch(:db_type)).to eq("numeric(10,0)")
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[20]
      expect(name).to eq(:number6)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:decimal)
      expect(options.fetch(:db_type)).to eq("numeric(10,2)")
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[21]
      expect(name).to eq(:number7)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:decimal)
      expect(options.fetch(:db_type)).to eq("numeric")
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[22]
      expect(name).to eq(:date1)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:date)
      expect(options.fetch(:db_type)).to eq("date")
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[23]
      expect(name).to eq(:date2)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:datetime)
      expect(options.fetch(:db_type)).to eq("timestamp without time zone")
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[24]
      expect(name).to eq(:time1)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:datetime)
      expect(options.fetch(:db_type)).to eq("timestamp without time zone")
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[25]
      expect(name).to eq(:time2)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:time)
      expect(options.fetch(:db_type)).to eq("time without time zone")
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[26]
      expect(name).to eq(:boolean1)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:boolean)
      expect(options.fetch(:db_type)).to eq("boolean")
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[27]
      expect(name).to eq(:boolean2)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:boolean)
      expect(options.fetch(:db_type)).to eq("boolean")
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[28]
      expect(name).to eq(:array1)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:integer)
      expect(options.fetch(:db_type)).to eq("integer[]")
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[29]
      expect(name).to eq(:array2)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:integer)
      expect(options.fetch(:db_type)).to eq("integer[]")
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[30]
      expect(name).to eq(:array3)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:string)
      expect(options.fetch(:db_type)).to eq("text[]")
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[31]
      expect(name).to eq(:money1)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      # expect(options.fetch(:type)).to eq(:money)
      expect(options.fetch(:db_type)).to eq("money")
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[32]
      expect(name).to eq(:enum1)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      # expect(options.fetch(:type)).to eq(:mood)
      expect(options.fetch(:db_type)).to eq("mood")
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[33]
      expect(name).to eq(:geometric1)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      # expect(options.fetch(:type)).to eq(:point)
      expect(options.fetch(:db_type)).to eq("point")
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[34]
      expect(name).to eq(:geometric2)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      # expect(options.fetch(:type)).to eq(:line)
      expect(options.fetch(:db_type)).to eq("line")
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[35]
      expect(name).to eq(:geometric3)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq("'<(15,15),1>'::circle")
      # expect(options.fetch(:type)).to eq(:circle)
      expect(options.fetch(:db_type)).to eq("circle")
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[36]
      expect(name).to eq(:net1)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq("'192.168.0.0/24'::cidr")
      # expect(options.fetch(:type)).to eq(:cidr)
      expect(options.fetch(:db_type)).to eq("cidr")
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[37]
      expect(name).to eq(:uuid1)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq("uuid_generate_v4()")
      # expect(options.fetch(:type)).to eq(:uuid)
      expect(options.fetch(:db_type)).to eq("uuid")
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[38]
      expect(name).to eq(:xml1)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      # expect(options.fetch(:type)).to eq(:xml)
      expect(options.fetch(:db_type)).to eq("xml")
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[39]
      expect(name).to eq(:json1)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      # expect(options.fetch(:type)).to eq(:json)
      expect(options.fetch(:db_type)).to eq("json")
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[40]
      expect(name).to eq(:json2)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      # expect(options.fetch(:type)).to eq(:jsonb)
      expect(options.fetch(:db_type)).to eq("jsonb")
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[41]
      expect(name).to eq(:composite1)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq("ROW('fuzzy dice'::text, 42, 1.99)")
      # expect(options.fetch(:type)).to eq(:inventory_item)
      expect(options.fetch(:db_type)).to eq("inventory_item")
      expect(options.fetch(:primary_key)).to eq(false)
    end

    it "defines column defaults" do
      table = @connection.schema(:default_values)

      name, options = table[0]
      expect(name).to eq(:a)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq("23")
      expect(options.fetch(:ruby_default)).to eq(23)
      expect(options.fetch(:type)).to eq(:integer)
      expect(options.fetch(:db_type)).to eq("integer")
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[1]
      expect(name).to eq(:b)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq("'Hanami'::text")
      expect(options.fetch(:ruby_default)).to eq("Hanami")
      expect(options.fetch(:type)).to eq(:string)
      expect(options.fetch(:db_type)).to eq("text")
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[2]
      expect(name).to eq(:c)

      expect(options.fetch(:allow_null)).to eq(true)

      expected = Platform.match do
        default { "'-1'::integer" }
      end

      expect(options.fetch(:default)).to eq(expected)

      # expect(options.fetch(:ruby_default)).to eq(-1)
      expect(options.fetch(:type)).to eq(:integer)
      expect(options.fetch(:db_type)).to eq("integer")
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[3]
      expect(name).to eq(:d)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq("0")
      expect(options.fetch(:ruby_default)).to eq(0)
      expect(options.fetch(:type)).to eq(:integer)
      expect(options.fetch(:db_type)).to eq("bigint")
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[4]
      expect(name).to eq(:e)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq("3.14")
      expect(options.fetch(:ruby_default)).to eq(3.14)
      expect(options.fetch(:type)).to eq(:float)
      expect(options.fetch(:db_type)).to eq("double precision")
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[5]
      expect(name).to eq(:f)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq("1.0")
      expect(options.fetch(:ruby_default)).to eq(1.0)
      expect(options.fetch(:type)).to eq(:decimal)
      expect(options.fetch(:db_type)).to eq("numeric")
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[6]
      expect(name).to eq(:g)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq("943943")
      expect(options.fetch(:ruby_default)).to eq(943_943)
      expect(options.fetch(:type)).to eq(:decimal)
      expect(options.fetch(:db_type)).to eq("numeric")
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[10]
      expect(name).to eq(:k)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq("true")
      expect(options.fetch(:ruby_default)).to eq(true)
      expect(options.fetch(:type)).to eq(:boolean)
      expect(options.fetch(:db_type)).to eq("boolean")
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[11]
      expect(name).to eq(:l)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq("false")
      expect(options.fetch(:ruby_default)).to eq(false)
      expect(options.fetch(:type)).to eq(:boolean)
      expect(options.fetch(:db_type)).to eq("boolean")
      expect(options.fetch(:primary_key)).to eq(false)
    end

    it "defines null constraint" do
      table = @connection.schema(:null_constraints)

      name, options = table[0]
      expect(name).to eq(:a)

      expect(options.fetch(:allow_null)).to eq(true)

      name, options = table[1]
      expect(name).to eq(:b)

      expect(options.fetch(:allow_null)).to eq(false)

      name, options = table[2]
      expect(name).to eq(:c)

      expect(options.fetch(:allow_null)).to eq(true)
    end

    it "defines column index" do
      indexes = @connection.indexes(:column_indexes)

      expect(indexes.fetch(:column_indexes_a_index, nil)).to be_nil
      expect(indexes.fetch(:column_indexes_b_index, nil)).to be_nil

      index = indexes.fetch(:column_indexes_c_index)
      expect(index[:unique]).to eq(false)
      expect(index[:columns]).to eq([:c])
    end

    it "defines index via #index" do
      indexes = @connection.indexes(:column_indexes)

      index = indexes.fetch(:column_indexes_d_index)
      expect(index[:unique]).to eq(true)
      expect(index[:columns]).to eq([:d])

      index = indexes.fetch(:column_indexes_b_c_index)
      expect(index[:unique]).to eq(false)
      expect(index[:columns]).to eq(%i[b c])

      index = indexes.fetch(:column_indexes_coords_index)
      expect(index[:unique]).to eq(false)
      expect(index[:columns]).to eq(%i[lat lng])
    end

    it "defines primary key (via #primary_key :id)" do
      table = @connection.schema(:primary_keys_1)

      name, options = table[0]
      expect(name).to eq(:id)

      expect(options.fetch(:allow_null)).to eq(false)
      expect(options.fetch(:default)).to eq("nextval('primary_keys_1_id_seq'::regclass)")
      expect(options.fetch(:type)).to eq(:integer)
      expect(options.fetch(:db_type)).to eq("integer")
      expect(options.fetch(:primary_key)).to eq(true)
      expect(options.fetch(:auto_increment)).to eq(true)
    end

    it "defines composite primary key (via #primary_key [:column1, :column2])" do
      table = @connection.schema(:primary_keys_3)

      name, options = table[0]
      expect(name).to eq(:group_id)

      expect(options.fetch(:allow_null)).to eq(false)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:integer)
      expect(options.fetch(:db_type)).to eq("integer")
      expect(options.fetch(:primary_key)).to eq(true)
      expect(options.fetch(:auto_increment)).to eq(false)

      name, options = table[1]
      expect(name).to eq(:position)

      expect(options.fetch(:allow_null)).to eq(false)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:integer)
      expect(options.fetch(:db_type)).to eq("integer")
      expect(options.fetch(:primary_key)).to eq(true)
      expect(options.fetch(:auto_increment)).to eq(false)
    end

    it "defines primary key (via #column primary_key: true)" do
      table = @connection.schema(:primary_keys_2)

      name, options = table[0]
      expect(name).to eq(:name)

      expect(options.fetch(:allow_null)).to eq(false)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:string)
      expect(options.fetch(:db_type)).to eq("text")
      expect(options.fetch(:primary_key)).to eq(true)
      expect(options.fetch(:auto_increment)).to eq(false)
    end

    it "defines foreign key (via #foreign_key)" do
      table = @connection.schema(:albums)

      name, options = table[1]
      expect(name).to eq(:artist_id)

      expect(options.fetch(:allow_null)).to eq(false)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:integer)
      expect(options.fetch(:db_type)).to eq("integer")
      expect(options.fetch(:primary_key)).to eq(false)

      foreign_key = @connection.foreign_key_list(:albums).first
      expect(foreign_key.fetch(:columns)).to eq([:artist_id])
      expect(foreign_key.fetch(:table)).to eq(:artists)
      expect(foreign_key.fetch(:key)).to eq([:id])
      expect(foreign_key.fetch(:on_update)).to eq(:no_action)
      expect(foreign_key.fetch(:on_delete)).to eq(:cascade)
    end

    unless Platform.ci?
      it "defines column constraint and check" do
        actual = @schema.read

        expect(actual).to include %(CONSTRAINT age_constraint CHECK ((age > 18)))
        expect(actual).to include %(CONSTRAINT table_constraints_role_check CHECK ((role = ANY (ARRAY['contributor'::text, 'manager'::text, 'owner'::text]))))
      end
    end
  end
end
