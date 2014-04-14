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
          # TODO consider to make this lazy (aka remove #all)
          query(collection).all
        end

        def find(collection, id)
          _first(
            _find(collection, id)
          )
        end

        def first(collection)
          _first(
            query(collection).asc(_identity(collection))
          )
        end

        def last(collection)
          _first(
            query(collection).desc(_identity(collection))
          )
        end

        private
        def _collection(name)
          raise NotImplementedError
        end

        def _mapped_collection(name)
          @mapper.collection(name)
        end

        def _find(collection, id)
          identity = _identity(collection)
          query(collection).where(identity => _id(collection, identity, id))
        end

        def _first(query)
          query.limit(1).first
        end

        def _identity(collection)
          _mapped_collection(collection).identity
        end

        def _id(collection, column, value)
          _mapped_collection(collection).deserialize_attribute(column, value)
        end
      end
    end
  end
end
