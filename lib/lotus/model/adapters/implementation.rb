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
          # TODO DRY see #first, #last
          _find(collection, id).limit(1).first
        end

        def first(collection)
          # TODO DRY see #find, #last
          query(collection).asc(_identity(collection)).limit(1).first
        end

        def last(collection)
          # TODO DRY see #find, #first
          query(collection).desc(_identity(collection)).limit(1).first
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
