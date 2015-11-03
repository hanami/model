require 'test_helper'

describe Lotus::Model::Config::Adapter do

  describe 'initialize' do
    it 'sets other adapater options' do
      after_connect_proc = -> {}
      config =  Lotus::Model::Config::Adapter.new(type: :memory, uri: nil, after_connect: after_connect_proc)

      config.options.must_equal({after_connect: after_connect_proc})
    end
  end

  describe '#build' do
    let(:mapper) { Lotus::Model::Mapper.new }
    let(:adapter) { config.build(mapper) }

    describe 'given adapter type is memory' do
      let(:config) { Lotus::Model::Config::Adapter.new(type: :memory) }

      it 'instantiates memory adapter' do
        adapter = config.build(mapper)
        adapter.must_be_kind_of Lotus::Model::Adapters::MemoryAdapter
      end
    end

    describe 'given adapter type is SQL' do
      let(:config) { Lotus::Model::Config::Adapter.new(type: :sql, uri: SQLITE_CONNECTION_STRING) }

      it 'instantiates SQL adapter' do
        adapter = config.build(mapper)
        adapter.must_be_kind_of Lotus::Model::Adapters::SqlAdapter
      end
    end

    describe 'given adapter type is not found' do
      let(:config) { Lotus::Model::Config::Adapter.new(type: :redis, uri: 'redis://not_exist') }

      it 'raises an error' do
        -> { config.build(mapper) }.must_raise(LoadError)
      end
    end

    describe 'given adapter class is not found' do
      let(:config) { Lotus::Model::Config::Adapter.new(type: :redis, uri: SQLITE_CONNECTION_STRING) }

      it 'raises an error' do
        config.stub(:load_adapter, nil) do
          -> { config.build(mapper) }.must_raise(Lotus::Model::Config::AdapterNotFound)
        end
      end
    end
  end

end
