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
    before do
      configuration.mapping do
        collection :users do
          entity User

          attribute :id, Integer
          attribute :name, String
        end
      end
    end

    it 'instantiates the registered adapter (memory)' do
      configuration.adapter(type: :memory, uri: 'memory://localhost')
      configuration.load!

      adapter = configuration.instance_variable_get(:@adapter)
      adapter.must_be_instance_of Lotus::Model::Adapters::MemoryAdapter
    end

    it 'instantiates the registered adapter (file system)' do
      configuration.adapter(type: :file_system, uri: FILE_SYSTEM_CONNECTION_STRING)
      configuration.load!

      adapter = configuration.instance_variable_get(:@adapter)
      adapter.must_be_instance_of Lotus::Model::Adapters::FileSystemAdapter
    end

    it 'instantiates the registered adapter (sql)' do
      configuration.adapter(type: :sql, uri: SQLITE_CONNECTION_STRING)
      configuration.load!

      adapter = configuration.instance_variable_get(:@adapter)
      adapter.must_be_instance_of Lotus::Model::Adapters::SqlAdapter
    end

    it 'builds collections from mapping' do
      configuration.adapter(type: :memory, uri: 'memory://localhost')
      configuration.load!

      collection = configuration.mapper.collection(:users)
      collection.must_be_kind_of Lotus::Model::Mapping::Collection
      collection.name.must_equal :users
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

        assert configuration.instance_variable_get(:@mapping).is_a?(Proc)
      end
    end

    describe "when a path is given" do
      it 'configures the global persistence mapper through block' do
        configuration.mapping 'test/fixtures/mapping'

        mapping = configuration.instance_variable_get(:@mapping)
        assert mapping.is_a?(Proc)
      end
    end

    describe "when block and path are not given" do
      it 'raise error' do
        exception = -> { configuration.mapping }.must_raise Lotus::Model::InvalidMappingError
        exception.message.must_equal 'You must specify a block or a file.'
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
      configuration.adapter_config.must_be_nil
      configuration.instance_variable_get(:@adapter).must_be_nil
    end

    it 'resets mapper' do
      configuration.instance_variable_get(:@mapper_config).must_be_nil
      configuration.mapper.must_be_instance_of Lotus::Model::NullMapper
    end
  end
end
