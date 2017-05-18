RSpec.shared_examples 'migration_integration_sqlite' do
  before do
    @schema = Pathname.new("#{__dir__}/../../../tmp/schema.sql").expand_path
    @connection = Sequel.connect(ENV['HANAMI_DATABASE_URL'])

    Hanami::Model::Migrator::Adapter.for(Hanami::Model.configuration).dump
  end

  describe 'columns' do
    it 'defines column types' do
      table = @connection.schema(:column_types)

      name, options = table[0]
      expect(name).to eq(:integer1)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:integer)
      expect(options.fetch(:db_type)).to eq('integer')
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[1]
      expect(name).to eq(:integer2)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:integer)
      expect(options.fetch(:db_type)).to eq('integer')
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[2]
      expect(name).to eq(:integer3)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:integer)
      expect(options.fetch(:db_type)).to eq('integer')
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[3]
      expect(name).to eq(:string1)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:string)
      expect(options.fetch(:db_type)).to eq('varchar(255)')
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[4]
      expect(name).to eq(:string2)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:string)
      expect(options.fetch(:db_type)).to eq('string')
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[5]
      expect(name).to eq(:string3)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:string)
      expect(options.fetch(:db_type)).to eq('string')
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[6]
      expect(name).to eq(:string4)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:string)
      expect(options.fetch(:db_type)).to eq('varchar(3)')
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[7]
      expect(name).to eq(:string5)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:string)
      expect(options.fetch(:db_type)).to eq('varchar(50)')
      expect(options.fetch(:max_length)).to eq(50)
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[8]
      expect(name).to eq(:string6)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:string)
      expect(options.fetch(:db_type)).to eq('char(255)')
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[9]
      expect(name).to eq(:string7)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:string)
      expect(options.fetch(:db_type)).to eq('char(64)')
      expect(options.fetch(:max_length)).to eq(64)
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[10]
      expect(name).to eq(:string8)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:string)
      expect(options.fetch(:db_type)).to eq('text')
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[11]
      expect(name).to eq(:file1)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:blob)
      expect(options.fetch(:db_type)).to eq('blob')
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[12]
      expect(name).to eq(:file2)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:blob)
      expect(options.fetch(:db_type)).to eq('blob')
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[13]
      expect(name).to eq(:number1)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:integer)
      expect(options.fetch(:db_type)).to eq('integer')
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[14]
      expect(name).to eq(:number2)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:integer)
      expect(options.fetch(:db_type)).to eq('bigint')
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[15]
      expect(name).to eq(:number3)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:float)
      expect(options.fetch(:db_type)).to eq('double precision')
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[16]
      expect(name).to eq(:number4)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:decimal)
      expect(options.fetch(:db_type)).to eq('numeric')
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[17]
      expect(name).to eq(:number5)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      # expect(options.fetch(:type)).to eq(:decimal)
      expect(options.fetch(:db_type)).to eq('numeric(10)')
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[18]
      expect(name).to eq(:number6)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:decimal)
      expect(options.fetch(:db_type)).to eq('numeric(10, 2)')
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[19]
      expect(name).to eq(:number7)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:decimal)
      expect(options.fetch(:db_type)).to eq('numeric')
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[20]
      expect(name).to eq(:date1)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:date)
      expect(options.fetch(:db_type)).to eq('date')
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[21]
      expect(name).to eq(:date2)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:datetime)
      expect(options.fetch(:db_type)).to eq('timestamp')
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[22]
      expect(name).to eq(:time1)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:datetime)
      expect(options.fetch(:db_type)).to eq('timestamp')
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[23]
      expect(name).to eq(:time2)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:time)
      expect(options.fetch(:db_type)).to eq('time')
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[24]
      expect(name).to eq(:boolean1)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:boolean)
      expect(options.fetch(:db_type)).to eq('boolean')
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[25]
      expect(name).to eq(:boolean2)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:boolean)
      expect(options.fetch(:db_type)).to eq('boolean')
      expect(options.fetch(:primary_key)).to eq(false)
    end

    it 'defines column defaults' do
      table = @connection.schema(:default_values)

      name, options = table[0]
      expect(name).to eq(:a)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq('23')
      expect(options.fetch(:ruby_default)).to eq(23)
      expect(options.fetch(:type)).to eq(:integer)
      expect(options.fetch(:db_type)).to eq('integer')
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[1]
      expect(name).to eq(:b)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq("'Hanami'")
      expect(options.fetch(:ruby_default)).to eq('Hanami')
      expect(options.fetch(:type)).to eq(:string)
      expect(options.fetch(:db_type)).to eq('varchar(255)')
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[2]
      expect(name).to eq(:c)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq('-1')
      expect(options.fetch(:ruby_default)).to eq(-1)
      expect(options.fetch(:type)).to eq(:integer)
      expect(options.fetch(:db_type)).to eq('integer')
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[3]
      expect(name).to eq(:d)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq('0')
      expect(options.fetch(:ruby_default)).to eq(0)
      expect(options.fetch(:type)).to eq(:integer)
      expect(options.fetch(:db_type)).to eq('bigint')
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[4]
      expect(name).to eq(:e)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq('3.14')
      expect(options.fetch(:ruby_default)).to eq(3.14)
      expect(options.fetch(:type)).to eq(:float)
      expect(options.fetch(:db_type)).to eq('double precision')
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[5]
      expect(name).to eq(:f)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq('1.0')
      expect(options.fetch(:ruby_default)).to eq(1.0)
      expect(options.fetch(:type)).to eq(:decimal)
      expect(options.fetch(:db_type)).to eq('numeric')
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[6]
      expect(name).to eq(:g)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq('943943')
      expect(options.fetch(:ruby_default)).to eq(943_943)
      expect(options.fetch(:type)).to eq(:decimal)
      expect(options.fetch(:db_type)).to eq('numeric')
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[10]
      expect(name).to eq(:k)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq('1')
      expect(options.fetch(:ruby_default)).to eq(true)
      expect(options.fetch(:type)).to eq(:boolean)
      expect(options.fetch(:db_type)).to eq('boolean')
      expect(options.fetch(:primary_key)).to eq(false)

      name, options = table[11]
      expect(name).to eq(:l)

      expect(options.fetch(:allow_null)).to eq(true)
      expect(options.fetch(:default)).to eq('0')
      expect(options.fetch(:ruby_default)).to eq(false)
      expect(options.fetch(:type)).to eq(:boolean)
      expect(options.fetch(:db_type)).to eq('boolean')
      expect(options.fetch(:primary_key)).to eq(false)
    end

    it 'defines null constraint' do
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

    it 'defines column index' do
      indexes = @connection.indexes(:column_indexes)

      expect(indexes.fetch(:column_indexes_a_index, nil)).to be_nil
      expect(indexes.fetch(:column_indexes_b_index, nil)).to be_nil

      index = indexes.fetch(:column_indexes_c_index)
      expect(index[:unique]).to eq(false)
      expect(index[:columns]).to eq([:c])
    end

    it 'defines index via #index' do
      indexes = @connection.indexes(:column_indexes)

      index = indexes.fetch(:column_indexes_d_index)
      expect(index[:unique]).to eq(true)
      expect(index[:columns]).to eq([:d])

      index = indexes.fetch(:column_indexes_b_c_index)
      expect(index[:unique]).to eq(false)
      expect(index[:columns]).to eq([:b, :c])

      index = indexes.fetch(:column_indexes_coords_index)
      expect(index[:unique]).to eq(false)
      expect(index[:columns]).to eq([:lat, :lng])
    end

    it 'defines primary key (via #primary_key :id)' do
      table = @connection.schema(:primary_keys_1)

      name, options = table[0]
      expect(name).to eq(:id)

      expect(options.fetch(:allow_null)).to eq(false)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:integer)
      expect(options.fetch(:db_type)).to eq('integer')
      expect(options.fetch(:primary_key)).to eq(true)
      expect(options.fetch(:auto_increment)).to eq(true)
    end

    it 'defines composite primary key (via #primary_key [:column1, :column2])' do
      table = @connection.schema(:primary_keys_3)

      name, options = table[0]
      expect(name).to eq(:group_id)

      expect(options.fetch(:allow_null)).to eq(false)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:integer)
      expect(options.fetch(:db_type)).to eq('integer')
      expect(options.fetch(:primary_key)).to eq(true)
      expect(options.fetch(:auto_increment)).to eq(false)

      name, options = table[1]
      expect(name).to eq(:position)

      expect(options.fetch(:allow_null)).to eq(false)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:integer)
      expect(options.fetch(:db_type)).to eq('integer')
      expect(options.fetch(:primary_key)).to eq(true)
      expect(options.fetch(:auto_increment)).to eq(false)
    end

    it 'defines primary key (via #column primary_key: true)' do
      table = @connection.schema(:primary_keys_2)

      name, options = table[0]
      expect(name).to eq(:name)

      expect(options.fetch(:allow_null)).to eq(false)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:string)
      expect(options.fetch(:db_type)).to eq('varchar(255)')
      expect(options.fetch(:primary_key)).to eq(true)
      expect(options.fetch(:auto_increment)).to eq(false)
    end

    it 'defines foreign key (via #foreign_key)' do
      table = @connection.schema(:albums)

      name, options = table[1]
      expect(name).to eq(:artist_id)

      expect(options.fetch(:allow_null)).to eq(false)
      expect(options.fetch(:default)).to eq(nil)
      expect(options.fetch(:type)).to eq(:integer)
      expect(options.fetch(:db_type)).to eq('integer')
      expect(options.fetch(:primary_key)).to eq(false)

      foreign_key = @connection.foreign_key_list(:albums).first
      expect(foreign_key.fetch(:columns)).to eq([:artist_id])
      expect(foreign_key.fetch(:table)).to eq(:artists)
      expect(foreign_key.fetch(:key)).to eq(nil)
      expect(foreign_key.fetch(:on_update)).to eq(:no_action)
      expect(foreign_key.fetch(:on_delete)).to eq(:cascade)
    end

    it 'defines column constraint and check' do
      expect(@schema.read).to include %(CREATE TABLE `table_constraints` (`age` integer, `role` varchar(255), CONSTRAINT `age_constraint` CHECK (`age` > 18), CHECK (role IN("contributor", "manager", "owner")));)
    end
  end
end
