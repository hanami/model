require 'test_helper'

describe Lotus::Model::Configuration do
  let(:configuration) { Lotus::Model::Configuration.new }

  describe '#adapter_config' do
    it 'defaults to an empty set' do
      configuration.adapter_config.must_be_nil
      configuration.instance_variable_get(:@adapter).must_be_nil
    end

    it 'allows to register adapter configuration' do
      configuration.adapter(type: :sql, uri: SQLITE_CONNECTION_STRING)

      adapter_config = configuration.adapter_config
      adapter_config.must_be_instance_of Lotus::Model::Config::Adapter
      adapter_config.uri.must_equal SQLITE_CONNECTION_STRING
    end

    it 'avoids duplication' do
      configuration.adapter(type: :sql, uri: 'sqlite3://uri')
      configuration.adapter(type: :memory, uri: 'memory://uri')

      configuration.adapter_config.type.must_equal :sql
    end

    it 'raises error when :type is omitted' do
      exception = -> { configuration.adapter(uri: SQLITE_CONNECTION_STRING) }.must_raise(ArgumentError)
      exception.message.must_equal 'missing keyword: type'
    end

    it 'raises error when :uri is omitted' do
      exception = -> { configuration.adapter(type: :memory) }.must_raise(ArgumentError)
      exception.message.must_equal 'missing keyword: uri'
    end
  end

  describe '#load!' do
    it 'instantiates all registered adapters' do
      configuration.mapping do
        collection :users do
          entity User

          attribute :id, Integer
          attribute :name, String
        end
      end

      configuration.adapter(type: :memory, uri: 'memory://localhost')
      configuration.load!

      adapter = configuration.instance_variable_get(:@adapter)
      adapter.must_be_instance_of Lotus::Model::Adapters::MemoryAdapter
    end
  end

  describe '#mapping' do
    describe "when a block is given" do
      it 'configures the global persistence mapper through block' do
        configuration.mapping do
          collection :users do
            entity User

            attribute :id, Integer
            attribute :name, String
          end
        end

        collection = configuration.mapper.collection(:users)
        collection.must_be_instance_of Lotus::Model::Mapping::Collection
        collection.name.must_equal :users
      end
    end

    describe "when a block isn't given" do
      it 'defaults to the null' do
        -> { configuration.mapping }.must_raise Lotus::Model::InvalidMappingError
      end
    end
  end

  describe '#reset!' do
    before do
      configuration.adapter(type: :sql, uri: SQLITE_CONNECTION_STRING)
      configuration.mapping do
        collection :users do
          entity User

          attribute :id, Integer
          attribute :name, String
        end
      end

      configuration.load!
      configuration.reset!
    end

    it 'resets adapter' do
      configuration.adapter_config.must_equal nil
      configuration.instance_variable_get(:@adapter).must_equal nil
    end

    it 'resets mapper' do
      configuration.mapper.must_equal nil
    end
  end

end
