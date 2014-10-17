require 'test_helper'

describe Lotus::Model::AdapterRegistry do

  let(:registry) { Lotus::Model::AdapterRegistry.new }

  describe '#initialize' do
    it 'sets default values' do
      registry.adapter_configs.must_equal({})
      registry.adapters.must_equal({})
    end
  end

  describe '#reset!' do
    before do
      mapper = Lotus::Model::Mapper.new
      registry.register(:cache, :memory, nil)
      registry.build(mapper)
    end

    it 'resets adapter configurations' do
      registry.adapter_configs.wont_equal({})
      registry.adapters.wont_equal({})

      registry.reset!

      registry.adapter_configs.must_equal({})
      registry.adapters.must_equal({})
    end
  end

  describe '#register' do
    it 'adds new adapter config' do
      registry.adapter_configs.must_equal({})

      registry.register(:cache, :memory, nil)

      registry.adapter_configs.wont_equal({})
    end

    describe 'when default parameter is set' do
      it 'adds new adapter default' do
        registry.adapter_configs.must_equal({})

        registry.register(:sqlite3, :sql, SQLITE_CONNECTION_STRING)
        registry.register(:cache, :memory, nil, default: true)

        registry.adapter_configs.default.name.must_equal(:memory)
      end
    end

    describe 'when register the first adapter' do
      it 'makes the adapter default' do
        registry.adapter_configs.must_equal({})

        registry.register(:cache, :memory, nil)

        registry.adapter_configs.default.wont_be_nil
      end
    end
  end

  describe '#build' do
    let(:mapper) { Lotus::Model::Mapper.new }

    before do
      registry.register(:cache, :memory, nil)
    end

    it 'instantiates registered adapters' do
      registry.adapters.must_equal({})

      registry.build(mapper)

      registry.adapters.wont_equal({})
      registry.adapters[:memory].must_be_instance_of Lotus::Model::Adapters::MemoryAdapter
    end

    it 'sets default adapter instance' do
      registry.adapters.default.must_be_nil

      registry.build(mapper)

      registry.adapters.default.must_be_instance_of Lotus::Model::Adapters::MemoryAdapter
    end
  end

end
