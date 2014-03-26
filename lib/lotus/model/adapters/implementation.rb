module Lotus
  module Model
    module Adapters
      module Implementation
        def persist(collection, entity)
          # FIXME use primary_key strategy instead of :id.
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
      end
    end
  end
end
