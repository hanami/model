require 'lotus/utils/kernel'

module Lotus
  module Model
    module Adapters
      module Implementation
        def persist(collection, entity)
          if entity.id
            update(collection, entity)
          else
            create(collection, entity)
          end
        end

        def all(collection)
          _collection(collection).all
        end

        def first(collection)
          _collection(collection).first
        end

        def query(collection, &blk)
          _deserialize(
            collection,
           _collection(collection).instance_exec(&blk).all
          )
        end

        private
        def _collection(name)
          raise NotImplementedError
        end

        def _query
          raise NotImplementedError
        end

        def _serialize(collection, entity)
          @mapper.serialize(collection, entity)
        end

        def _deserialize(collection, *records)
          @mapper.deserialize(collection, Lotus::Utils::Kernel.Array(records))
        end

        def _key(collection)
          @mapper.key(collection)
        end
      end
    end
  end
end
