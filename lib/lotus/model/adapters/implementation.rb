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

        private
        def _collection(name)
          raise NotImplementedError
        end

        def _serialize(collection, entity)
          @mapper.serialize(collection, entity)
        end

        def _deserialize(collection, *records)
          # TODO implement a converter like Kernel.Array in Lotus::Utils
          # so that, we can unify Array(records).flatten.compact.uniq
          @mapper.deserialize(collection, Array(records).flatten.compact)
        end

        def _key(collection)
          @mapper.key(collection)
        end
      end
    end
  end
end
