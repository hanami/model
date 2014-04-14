require 'lotus/model/adapters/abstract'
require 'lotus/model/adapters/implementation'
require 'lotus/model/adapters/memory/collection'
require 'lotus/model/adapters/memory/command'
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
            entity.id = command(collection).create(entity)
            entity
          end
        end

        def update(collection, entity)
          @mutex.synchronize do
            command(collection).update(entity)
          end
        end

        def delete(collection, entity)
          @mutex.synchronize do
            command(collection).delete(entity)
          end
        end

        def clear(collection)
          @mutex.synchronize do
            command(collection).clear
          end
        end

        def command(collection)
          Memory::Command.new(_collection(collection), @mapper)
        end

        def query(collection, &blk)
          @mutex.synchronize do
            Memory::Query.new(_collection(collection), @mapper, &blk)
          end
        end

        private
        def _collection(name)
          @collections[name] ||= Memory::Collection.new(name, @mapper.key(name))
        end
      end
    end
  end
end
