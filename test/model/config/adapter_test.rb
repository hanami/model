require 'test_helper'

describe Lotus::Model::Config::Adapter do

  describe '#build' do
    let(:mapper) { Lotus::Model::Mapper.new }
    let(:adapter) { config.build(mapper) }

    describe 'given adapter type is memory' do
      let(:config) { Lotus::Model::Config::Adapter.new(:memory) }

      it 'instantiates memory adapter' do
        adapter = config.build(mapper)
        adapter.must_be_kind_of Lotus::Model::Adapters::MemoryAdapter
      end
    end

    describe 'given adapter type is SQL' do
      let(:config) { Lotus::Model::Config::Adapter.new(:sql, SQLITE_CONNECTION_STRING) }

      it 'instantiates SQL adapter' do
        adapter = config.build(mapper)
        adapter.must_be_kind_of Lotus::Model::Adapters::SqlAdapter
      end
    end

    describe 'given adapter type does not exist' do
      let(:config) { Lotus::Model::Config::Adapter.new(:redis, 'redis://not_exist') }

      it 'raises an error' do
        -> {
          config.build(mapper)
        }.must_raise(Lotus::Model::Config::AdapterNotFound)
      end
    end

    describe 'given custom adapter class name is provided' do
      module Lotus
        module Model
          module Adapters
            class FakeRedis < Abstract
              def initialize(mapper, uri)
              end
            end
          end
        end
      end

      let(:config) { Lotus::Model::Config::Adapter.new(:redis, 'redis://not_exist', 'FakeRedis') }

      it 'instantiates custom type adapter' do
        adapter = config.build(mapper)
        adapter.must_be_kind_of Lotus::Model::Adapters::FakeRedis
      end
    end
  end

end
