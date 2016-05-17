require 'test_helper'
require 'hanami/utils'

describe Hanami::Model::Config::Adapter do

  describe 'initialize' do
    it 'sets other adapater options' do
      after_connect_proc = -> {}
      config =  Hanami::Model::Config::Adapter.new(type: :memory, uri: MEMORY_CONNECTION_STRING, after_connect: after_connect_proc)

      config.options.must_equal({after_connect: after_connect_proc})
    end
  end

  describe '#build' do
    let(:mapper) { Hanami::Model::Mapper.new }
    let(:adapter) { config.build(mapper) }

    describe 'given adapter type is memory' do
      let(:config) { Hanami::Model::Config::Adapter.new(type: :memory, uri: MEMORY_CONNECTION_STRING) }

      it 'instantiates memory adapter' do
        adapter = config.build(mapper)
        adapter.must_be_kind_of Hanami::Model::Adapters::MemoryAdapter
      end
    end

    describe 'given adapter type is SQL' do
      let(:config) { Hanami::Model::Config::Adapter.new(type: :sql, uri: SQLITE_CONNECTION_STRING) }

      it 'instantiates SQL adapter' do
        adapter = config.build(mapper)
        adapter.must_be_kind_of Hanami::Model::Adapters::SqlAdapter
      end
    end

    describe 'given adapter type is not found' do
      let(:config) { Hanami::Model::Config::Adapter.new(type: :redis, uri: 'redis://not_exist') }

      it 'raises an error' do
        exception = -> { config.build(mapper) }.must_raise(Hanami::Model::Error)

        if Hanami::Utils.jruby?
          exception.message.must_equal "Cannot find Hanami::Model adapter `Hanami::Model::Adapters::RedisAdapter' (no such file to load -- hanami/model/adapters/redis_adapter)"
        else
          exception.message.must_equal "Cannot find Hanami::Model adapter `Hanami::Model::Adapters::RedisAdapter' (cannot load such file -- hanami/model/adapters/redis_adapter)"
        end
      end
    end

    describe 'given adapter class is not found' do
      let(:config) { Hanami::Model::Config::Adapter.new(type: :redis, uri: SQLITE_CONNECTION_STRING) }

      it 'raises an error' do
        config.stub(:load_adapter, nil) do
          exception = -> { config.build(mapper) }.must_raise(Hanami::Model::Error)

          if RUBY_VERSION >= "2.3" || Hanami::Utils.jruby?
            exception.message.must_equal "uninitialized constant Hanami::Model::Adapters::RedisAdapter"
          else
            exception.message.must_equal "uninitialized constant RedisAdapter"
          end
        end
      end
    end
  end

end
