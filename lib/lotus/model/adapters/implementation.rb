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
          query(collection).asc(_key(collection)).limit(1).first
        end

        def last(collection)
          # TODO DRY see #find, #first
          query(collection).desc(_key(collection)).limit(1).first
        end

        private
        def _collection(name)
          raise NotImplementedError
        end

        def _find(collection, id)
          key = _key(collection)
          query(collection).where(key => _id(collection, key, id))
        end

        # FIXME rename into _identity
        def _key(collection)
          @mapper.key(collection)
        end

        def _id(collection, key, value)
          @mapper.deserialize_column(collection, key, value)
        end
      end
    end
  end
end
