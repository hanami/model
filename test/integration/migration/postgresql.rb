describe 'PostgreSQL' do
  before do
    @schema     = Pathname.new("#{__dir__}/../../../tmp/schema.sql").expand_path
    @connection = Sequel.connect(ENV['HANAMI_DATABASE_URL'])

    Hanami::Model::Migrator::Adapter.for(Hanami::Model.configuration).dump
  end

  describe 'columns' do
    it 'defines column types' do
      table = @connection.schema(:column_types)

      name, options = table[0]
      name.must_equal :integer1

      options.fetch(:allow_null).must_equal  true
      options.fetch(:default).must_be_nil
      options.fetch(:type).must_equal        :integer
      options.fetch(:db_type).must_equal     'integer'
      options.fetch(:primary_key).must_equal false

      name, options = table[1]
      name.must_equal :integer2

      options.fetch(:allow_null).must_equal  true
      options.fetch(:default).must_be_nil
      options.fetch(:type).must_equal        :integer
      options.fetch(:db_type).must_equal     'integer'
      options.fetch(:primary_key).must_equal false

      name, options = table[2]
      name.must_equal :integer3

      options.fetch(:allow_null).must_equal  true
      options.fetch(:default).must_be_nil
      options.fetch(:type).must_equal        :integer
      options.fetch(:db_type).must_equal     'integer'
      options.fetch(:primary_key).must_equal false

      name, options = table[3]
      name.must_equal :string1

      options.fetch(:allow_null).must_equal  true
      options.fetch(:default).must_be_nil
      options.fetch(:type).must_equal        :string
      options.fetch(:db_type).must_equal     'text'
      options.fetch(:primary_key).must_equal false

      name, options = table[4]
      name.must_equal :string2

      options.fetch(:allow_null).must_equal  true
      options.fetch(:default).must_be_nil
      options.fetch(:type).must_equal        :string
      options.fetch(:db_type).must_equal     'text'
      options.fetch(:primary_key).must_equal false

      name, options = table[5]
      name.must_equal :string3

      options.fetch(:allow_null).must_equal  true
      options.fetch(:default).must_be_nil
      options.fetch(:type).must_equal        :string
      options.fetch(:db_type).must_equal     'character varying(1)'
      options.fetch(:primary_key).must_equal false

      name, options = table[6]
      name.must_equal :string4

      options.fetch(:allow_null).must_equal  true
      options.fetch(:default).must_be_nil
      options.fetch(:type).must_equal        :string
      options.fetch(:db_type).must_equal     'character varying(2)'
      options.fetch(:primary_key).must_equal false

      name, options = table[7]
      name.must_equal :string5

      options.fetch(:allow_null).must_equal  true
      options.fetch(:default).must_be_nil
      options.fetch(:type).must_equal        :string
      options.fetch(:db_type).must_equal     'character(3)'
      options.fetch(:primary_key).must_equal false

      name, options = table[8]
      name.must_equal :string6

      options.fetch(:allow_null).must_equal  true
      options.fetch(:default).must_be_nil
      options.fetch(:type).must_equal        :string
      options.fetch(:db_type).must_equal     'character(4)'
      options.fetch(:primary_key).must_equal false

      name, options = table[9]
      name.must_equal :string7

      options.fetch(:allow_null).must_equal  true
      options.fetch(:default).must_be_nil
      options.fetch(:type).must_equal        :string
      options.fetch(:db_type).must_equal     'character varying(50)'
      options.fetch(:max_length).must_equal  50
      options.fetch(:primary_key).must_equal false

      name, options = table[10]
      name.must_equal :string8

      options.fetch(:allow_null).must_equal  true
      options.fetch(:default).must_be_nil
      options.fetch(:type).must_equal        :string
      options.fetch(:db_type).must_equal     'character(255)'
      options.fetch(:primary_key).must_equal false

      name, options = table[11]
      name.must_equal :string9

      options.fetch(:allow_null).must_equal  true
      options.fetch(:default).must_be_nil
      options.fetch(:type).must_equal        :string
      options.fetch(:db_type).must_equal     'character(64)'
      options.fetch(:max_length).must_equal  64
      options.fetch(:primary_key).must_equal false

      name, options = table[12]
      name.must_equal :string10

      options.fetch(:allow_null).must_equal  true
      options.fetch(:default).must_be_nil
      options.fetch(:type).must_equal        :string
      options.fetch(:db_type).must_equal     'text'
      options.fetch(:primary_key).must_equal false

      name, options = table[13]
      name.must_equal :file1

      options.fetch(:allow_null).must_equal  true
      options.fetch(:default).must_be_nil
      options.fetch(:type).must_equal        :blob
      options.fetch(:db_type).must_equal     'bytea'
      options.fetch(:primary_key).must_equal false

      name, options = table[14]
      name.must_equal :file2

      options.fetch(:allow_null).must_equal  true
      options.fetch(:default).must_be_nil
      options.fetch(:type).must_equal        :blob
      options.fetch(:db_type).must_equal     'bytea'
      options.fetch(:primary_key).must_equal false

      name, options = table[15]
      name.must_equal :number1

      options.fetch(:allow_null).must_equal  true
      options.fetch(:default).must_be_nil
      options.fetch(:type).must_equal        :integer
      options.fetch(:db_type).must_equal     'integer'
      options.fetch(:primary_key).must_equal false

      name, options = table[16]
      name.must_equal :number2

      options.fetch(:allow_null).must_equal  true
      options.fetch(:default).must_be_nil
      options.fetch(:type).must_equal        :integer
      options.fetch(:db_type).must_equal     'bigint'
      options.fetch(:primary_key).must_equal false

      name, options = table[17]
      name.must_equal :number3

      options.fetch(:allow_null).must_equal  true
      options.fetch(:default).must_be_nil
      options.fetch(:type).must_equal        :float
      options.fetch(:db_type).must_equal     'double precision'
      options.fetch(:primary_key).must_equal false

      name, options = table[18]
      name.must_equal :number4

      options.fetch(:allow_null).must_equal  true
      options.fetch(:default).must_be_nil
      options.fetch(:type).must_equal        :decimal
      options.fetch(:db_type).must_equal     'numeric'
      options.fetch(:primary_key).must_equal false

      name, options = table[19]
      name.must_equal :number5

      options.fetch(:allow_null).must_equal  true
      options.fetch(:default).must_be_nil
      # options.fetch(:type).must_equal        :decimal
      options.fetch(:db_type).must_equal     'numeric(10,0)'
      options.fetch(:primary_key).must_equal false

      name, options = table[20]
      name.must_equal :number6

      options.fetch(:allow_null).must_equal  true
      options.fetch(:default).must_be_nil
      options.fetch(:type).must_equal        :decimal
      options.fetch(:db_type).must_equal     'numeric(10,2)'
      options.fetch(:primary_key).must_equal false

      name, options = table[21]
      name.must_equal :number7

      options.fetch(:allow_null).must_equal  true
      options.fetch(:default).must_be_nil
      options.fetch(:type).must_equal        :decimal
      options.fetch(:db_type).must_equal     'numeric'
      options.fetch(:primary_key).must_equal false

      name, options = table[22]
      name.must_equal :date1

      options.fetch(:allow_null).must_equal  true
      options.fetch(:default).must_be_nil
      options.fetch(:type).must_equal        :date
      options.fetch(:db_type).must_equal     'date'
      options.fetch(:primary_key).must_equal false

      name, options = table[23]
      name.must_equal :date2

      options.fetch(:allow_null).must_equal  true
      options.fetch(:default).must_be_nil
      options.fetch(:type).must_equal        :datetime
      options.fetch(:db_type).must_equal     'timestamp without time zone'
      options.fetch(:primary_key).must_equal false

      name, options = table[24]
      name.must_equal :time1

      options.fetch(:allow_null).must_equal  true
      options.fetch(:default).must_be_nil
      options.fetch(:type).must_equal        :datetime
      options.fetch(:db_type).must_equal     'timestamp without time zone'
      options.fetch(:primary_key).must_equal false

      name, options = table[25]
      name.must_equal :time2

      options.fetch(:allow_null).must_equal  true
      options.fetch(:default).must_be_nil
      options.fetch(:type).must_equal        :time
      options.fetch(:db_type).must_equal     'time without time zone'
      options.fetch(:primary_key).must_equal false

      name, options = table[26]
      name.must_equal :boolean1

      options.fetch(:allow_null).must_equal  true
      options.fetch(:default).must_be_nil
      options.fetch(:type).must_equal        :boolean
      options.fetch(:db_type).must_equal     'boolean'
      options.fetch(:primary_key).must_equal false

      name, options = table[27]
      name.must_equal :boolean2

      options.fetch(:allow_null).must_equal  true
      options.fetch(:default).must_be_nil
      options.fetch(:type).must_equal        :boolean
      options.fetch(:db_type).must_equal     'boolean'
      options.fetch(:primary_key).must_equal false

      name, options = table[28]
      name.must_equal :array1

      options.fetch(:allow_null).must_equal  true
      options.fetch(:default).must_be_nil
      options.fetch(:type).must_equal        :integer
      options.fetch(:db_type).must_equal     'integer[]'
      options.fetch(:primary_key).must_equal false

      name, options = table[29]
      name.must_equal :array2

      options.fetch(:allow_null).must_equal  true
      options.fetch(:default).must_be_nil
      options.fetch(:type).must_equal        :integer
      options.fetch(:db_type).must_equal     'integer[]'
      options.fetch(:primary_key).must_equal false

      name, options = table[30]
      name.must_equal :array3

      options.fetch(:allow_null).must_equal  true
      options.fetch(:default).must_be_nil
      options.fetch(:type).must_equal        :string
      options.fetch(:db_type).must_equal     'text[]'
      options.fetch(:primary_key).must_equal false

      name, options = table[31]
      name.must_equal :money1

      options.fetch(:allow_null).must_equal  true
      options.fetch(:default).must_be_nil
      # options.fetch(:type).must_equal        :money
      options.fetch(:db_type).must_equal     'money'
      options.fetch(:primary_key).must_equal false

      name, options = table[32]
      name.must_equal :enum1

      options.fetch(:allow_null).must_equal  true
      options.fetch(:default).must_be_nil
      # options.fetch(:type).must_equal        :mood
      options.fetch(:db_type).must_equal     'mood'
      options.fetch(:primary_key).must_equal false

      name, options = table[33]
      name.must_equal :geometric1

      options.fetch(:allow_null).must_equal  true
      options.fetch(:default).must_be_nil
      # options.fetch(:type).must_equal        :point
      options.fetch(:db_type).must_equal     'point'
      options.fetch(:primary_key).must_equal false

      name, options = table[34]
      name.must_equal :geometric2

      options.fetch(:allow_null).must_equal  true
      options.fetch(:default).must_be_nil
      # options.fetch(:type).must_equal        :line
      options.fetch(:db_type).must_equal     'line'
      options.fetch(:primary_key).must_equal false

      name, options = table[35]
      name.must_equal :geometric3

      options.fetch(:allow_null).must_equal  true
      options.fetch(:default).must_equal     "'<(15,15),1>'::circle"
      # options.fetch(:type).must_equal        :circle
      options.fetch(:db_type).must_equal     'circle'
      options.fetch(:primary_key).must_equal false

      name, options = table[36]
      name.must_equal :net1

      options.fetch(:allow_null).must_equal  true
      options.fetch(:default).must_equal     "'192.168.0.0/24'::cidr"
      # options.fetch(:type).must_equal        :cidr
      options.fetch(:db_type).must_equal     'cidr'
      options.fetch(:primary_key).must_equal false

      name, options = table[37]
      name.must_equal :uuid1

      options.fetch(:allow_null).must_equal  true
      options.fetch(:default).must_equal     'uuid_generate_v4()'
      # options.fetch(:type).must_equal        :uuid
      options.fetch(:db_type).must_equal     'uuid'
      options.fetch(:primary_key).must_equal false

      name, options = table[38]
      name.must_equal :xml1

      options.fetch(:allow_null).must_equal  true
      options.fetch(:default).must_be_nil
      # options.fetch(:type).must_equal        :xml
      options.fetch(:db_type).must_equal     'xml'
      options.fetch(:primary_key).must_equal false

      name, options = table[39]
      name.must_equal :json1

      options.fetch(:allow_null).must_equal  true
      options.fetch(:default).must_be_nil
      # options.fetch(:type).must_equal        :json
      options.fetch(:db_type).must_equal     'json'
      options.fetch(:primary_key).must_equal false

      name, options = table[40]
      name.must_equal :json2

      options.fetch(:allow_null).must_equal  true
      options.fetch(:default).must_be_nil
      # options.fetch(:type).must_equal        :jsonb
      options.fetch(:db_type).must_equal     'jsonb'
      options.fetch(:primary_key).must_equal false

      name, options = table[41]
      name.must_equal :composite1

      options.fetch(:allow_null).must_equal  true
      options.fetch(:default).must_equal     "ROW('fuzzy dice'::text, 42, 1.99)"
      # options.fetch(:type).must_equal        :inventory_item
      options.fetch(:db_type).must_equal     'inventory_item'
      options.fetch(:primary_key).must_equal false
    end

    it 'defines column defaults' do
      table = @connection.schema(:default_values)

      name, options = table[0]
      name.must_equal :a

      options.fetch(:allow_null).must_equal  true
      options.fetch(:default).must_equal     '23'
      options.fetch(:ruby_default).must_equal 23
      options.fetch(:type).must_equal        :integer
      options.fetch(:db_type).must_equal     'integer'
      options.fetch(:primary_key).must_equal false

      name, options = table[1]
      name.must_equal :b

      options.fetch(:allow_null).must_equal  true
      options.fetch(:default).must_equal     "'Hanami'::text"
      options.fetch(:ruby_default).must_equal 'Hanami'
      options.fetch(:type).must_equal        :string
      options.fetch(:db_type).must_equal     'text'
      options.fetch(:primary_key).must_equal false

      name, options = table[2]
      name.must_equal :c

      options.fetch(:allow_null).must_equal true

      expected = Platform.match do
        os(:linux) { '(-1)' }
        os(:macos) { "'-1'::integer" }
      end

      options.fetch(:default).must_equal expected

      # options.fetch(:ruby_default).must_equal(-1)
      options.fetch(:type).must_equal        :integer
      options.fetch(:db_type).must_equal     'integer'
      options.fetch(:primary_key).must_equal false

      name, options = table[3]
      name.must_equal :d

      options.fetch(:allow_null).must_equal  true
      options.fetch(:default).must_equal     '0'
      options.fetch(:ruby_default).must_equal 0
      options.fetch(:type).must_equal        :integer
      options.fetch(:db_type).must_equal     'bigint'
      options.fetch(:primary_key).must_equal false

      name, options = table[4]
      name.must_equal :e

      options.fetch(:allow_null).must_equal  true
      options.fetch(:default).must_equal     '3.14'
      options.fetch(:ruby_default).must_equal 3.14
      options.fetch(:type).must_equal        :float
      options.fetch(:db_type).must_equal     'double precision'
      options.fetch(:primary_key).must_equal false

      name, options = table[5]
      name.must_equal :f

      options.fetch(:allow_null).must_equal  true
      options.fetch(:default).must_equal     '1.0'
      options.fetch(:ruby_default).must_equal 1.0
      options.fetch(:type).must_equal        :decimal
      options.fetch(:db_type).must_equal     'numeric'
      options.fetch(:primary_key).must_equal false

      name, options = table[6]
      name.must_equal :g

      options.fetch(:allow_null).must_equal  true
      options.fetch(:default).must_equal     '943943'
      options.fetch(:ruby_default).must_equal 943_943
      options.fetch(:type).must_equal        :decimal
      options.fetch(:db_type).must_equal     'numeric'
      options.fetch(:primary_key).must_equal false

      name, options = table[10]
      name.must_equal :k

      options.fetch(:allow_null).must_equal  true
      options.fetch(:default).must_equal     'true'
      options.fetch(:ruby_default).must_equal true
      options.fetch(:type).must_equal        :boolean
      options.fetch(:db_type).must_equal     'boolean'
      options.fetch(:primary_key).must_equal false

      name, options = table[11]
      name.must_equal :l

      options.fetch(:allow_null).must_equal  true
      options.fetch(:default).must_equal     'false'
      options.fetch(:ruby_default).must_equal false
      options.fetch(:type).must_equal        :boolean
      options.fetch(:db_type).must_equal     'boolean'
      options.fetch(:primary_key).must_equal false
    end

    it 'defines null constraint' do
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

    it 'defines column index' do
      indexes = @connection.indexes(:column_indexes)

      indexes.fetch(:column_indexes_a_index, nil).must_be_nil
      indexes.fetch(:column_indexes_b_index, nil).must_be_nil

      index = indexes.fetch(:column_indexes_c_index)
      index[:unique].must_equal false
      index[:columns].must_equal [:c]
    end

    it 'defines index via #index' do
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

    it 'defines primary key (via #primary_key :id)' do
      table = @connection.schema(:primary_keys_1)

      name, options = table[0]
      name.must_equal :id

      options.fetch(:allow_null).must_equal     false
      options.fetch(:default).must_equal        "nextval('primary_keys_1_id_seq'::regclass)"
      options.fetch(:type).must_equal           :integer
      options.fetch(:db_type).must_equal        'integer'
      options.fetch(:primary_key).must_equal    true
      options.fetch(:auto_increment).must_equal true
    end

    it 'defines composite primary key (via #primary_key [:column1, :column2])' do
      table = @connection.schema(:primary_keys_3)

      name, options = table[0]
      name.must_equal :group_id

      options.fetch(:allow_null).must_equal     false
      options.fetch(:default).must_be_nil
      options.fetch(:type).must_equal           :integer
      options.fetch(:db_type).must_equal        'integer'
      options.fetch(:primary_key).must_equal    true
      options.fetch(:auto_increment).must_equal false

      name, options = table[1]
      name.must_equal :position

      options.fetch(:allow_null).must_equal     false
      options.fetch(:default).must_be_nil
      options.fetch(:type).must_equal           :integer
      options.fetch(:db_type).must_equal        'integer'
      options.fetch(:primary_key).must_equal    true
      options.fetch(:auto_increment).must_equal false
    end

    it 'defines primary key (via #column primary_key: true)' do
      table = @connection.schema(:primary_keys_2)

      name, options = table[0]
      name.must_equal :name

      options.fetch(:allow_null).must_equal     false
      options.fetch(:default).must_be_nil
      options.fetch(:type).must_equal           :string
      options.fetch(:db_type).must_equal        'text'
      options.fetch(:primary_key).must_equal    true
      options.fetch(:auto_increment).must_equal false
    end

    it 'defines foreign key (via #foreign_key)' do
      table = @connection.schema(:albums)

      name, options = table[1]
      name.must_equal :artist_id

      options.fetch(:allow_null).must_equal     false
      options.fetch(:default).must_be_nil
      options.fetch(:type).must_equal           :integer
      options.fetch(:db_type).must_equal        'integer'
      options.fetch(:primary_key).must_equal    false

      foreign_key = @connection.foreign_key_list(:albums).first
      foreign_key.fetch(:columns).must_equal   [:artist_id]
      foreign_key.fetch(:table).must_equal     :artists
      foreign_key.fetch(:key).must_equal       [:id]
      foreign_key.fetch(:on_update).must_equal :no_action
      foreign_key.fetch(:on_delete).must_equal :cascade
    end

    unless Platform.ci?
      it 'defines column constraint and check' do
        actual = @schema.read

        actual.must_include %(CONSTRAINT age_constraint CHECK ((age > 18)))
        actual.must_include %(CONSTRAINT table_constraints_role_check CHECK ((role = ANY (ARRAY['contributor'::text, 'manager'::text, 'owner'::text]))))
      end
    end
  end
end
