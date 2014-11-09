require 'test_helper'

describe Lotus::Model::Configuration do
  let(:configuration) { Lotus::Model::Configuration.new }

  describe '#adapter_configs' do
    it 'defaults to an empty set' do
      configuration.adapters.must_be_empty
    end

    it 'allows to register adapter configuration' do
      configuration.adapter(name: :sqlite3, type: :sql, uri: SQLITE_CONNECTION_STRING)

      adapter_config = configuration.adapter_registry.adapter_configs.fetch(:sqlite3)
      adapter_config.must_be_instance_of Lotus::Model::Config::Adapter
      adapter_config.uri.must_equal SQLITE_CONNECTION_STRING
    end

    it 'allows to register default adapter' do
      configuration.adapter(name: :sqlite3, type: :sql, uri: SQLITE_CONNECTION_STRING, default: true)

      default_adapter_config = configuration.adapter_registry.adapter_configs.default
      default_adapter_config.must_be_instance_of Lotus::Model::Config::Adapter
      default_adapter_config.uri.must_equal SQLITE_CONNECTION_STRING
    end

    it 'eliminates duplications' do
      configuration.adapter(name: :sqlite3, type: :sql, uri: SQLITE_CONNECTION_STRING)
      configuration.adapter(name: :sqlite3, type: :sql, uri: SQLITE_CONNECTION_STRING)

      configuration.adapter_registry.adapter_configs.select { |name, _| name == :sqlite3 }.size.must_equal(1)
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

      configuration.adapter(name: :cache, type: :memory)
      configuration.load!

      adapter = configuration.adapters.fetch(:cache)
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
end
