module Hanami
  module Model
    module Adapters
      # Shared implementation for SqlAdapter and MemoryAdapter
      #
      # @api private
      # @since 0.1.0
      module Implementation
        # Creates or updates a record in the database for the given entity.
        #
        # @param collection [Symbol] the target collection (it must be mapped).
        # @param entity [#id, #id=] the entity to persist
        #
        # @return [Object] the entity
        #
        # @api private
        # @since 0.1.0
        def persist(collection, entity)
          if entity.id
            update(collection, entity)
          else
            create(collection, entity)
          end
        end

        # Returns all the records for the given collection
        #
        # @param collection [Symbol] the target collection (it must be mapped).
        #
        # @return [Array] all the records
        #
        # @api private
        # @since 0.1.0
        def all(collection)
          # TODO consider to make this lazy (aka remove #all)
          query(collection).all
        end

        # Returns a unique record from the given collection, with the given
        # id.
        #
        # @param collection [Symbol] the target collection (it must be mapped).
        # @param id [Object] the identity of the object.
        #
        # @return [Object] the entity
        #
        # @api private
        # @since 0.1.0
        def find(collection, id)
          _first(
            _find(collection, id)
          )
        end

        # Returns the first record in the given collection.
        #
        # @param collection [Symbol] the target collection (it must be mapped).
        #
        # @return [Object] the first entity
        #
        # @api private
        # @since 0.1.0
        def first(collection)
          _first(
            query(collection).asc(_identity(collection))
          )
        end

        # Returns the last record in the given collection.
        #
        # @param collection [Symbol] the target collection (it must be mapped).
        #
        # @return [Object] the last entity
        #
        # @api private
        # @since 0.1.0
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
