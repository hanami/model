require 'lotus/model/adapters/abstract'
require 'lotus/model/adapters/implementation'
require 'lotus/model/adapters/memory/collection' # TODO remove this
require 'lotus/model/adapters/memory/query'

module Lotus
  module Model
    module Adapters
      class MemoryAdapter < Abstract
        include Implementation

        def initialize(mapper, uri = nil)
          super

          @mutex       = Mutex.new
          @collections = {}
        end

        def create(collection, entity)
          @mutex.synchronize do
            entity.id = _collection(collection).create(_serialize(collection, entity))
            entity
          end
        end

        def update(collection, entity)
          @mutex.synchronize do
            _collection(collection).update(_serialize(collection, entity))
          end
        end

        def delete(collection, entity)
          @mutex.synchronize do
            _collection(collection).delete(entity)
          end
        end

        def clear(collection)
          @mutex.synchronize do
            _collection(collection).clear
          end
        end

        def query(collection, &blk)
          @mutex.synchronize do
            _query.new(_collection(collection), @mapper, &blk)
          end
        end

        private
        def _collection(name)
          @collections[name] ||= Memory::Collection.new(name, @mapper.key(name))
        end

        def _query
          # FIXME Dependency injection
          Memory::Query
        end
      end
    end
  end
end
