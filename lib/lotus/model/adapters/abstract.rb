module Lotus
  module Model
    module Adapters
      # It's raised when an adapter can't find the underlying database adapter.
      #
      # Example: When we try to use the SqlAdapter with a Postgres database
      # but we didn't loaded the pg gem before.
      #
      # @see Lotus::Model::Adapters::SqlAdapter#initialize
      #
      # @since 0.1.0
      class DatabaseAdapterNotFound < ::StandardError
      end

      # It's raised when an adapter does not support a feature.
      #
      # Example: When we try to get a connection string for the current database
      # but the adapter has not implemented it.
      #
      # @see Lotus::Model::Adapters::Abstract#connection_string
      #
      # @since 0.3.0
      class NotSupportedError < ::StandardError
      end

      # Abstract adapter.
      #
      # An adapter is a concrete implementation that allows a repository to
      # communicate with a single database.
      #
      # Lotus::Model is shipped with Memory and SQL adapters.
      # Third part adapters MUST implement the interface defined here.
      # For convenience they may inherit from this class.
      #
      # These are low level details, and shouldn't be used directly.
      # Please use a repository for entities persistence.
      #
      # @since 0.1.0
      class Abstract
        # Initialize the adapter
        #
        # @param mapper [Lotus::Model::Mapper] the object that defines the
        #   database to entities mapping
        #
        # @param uri [String] the optional connection string to the database
        #
        # @since 0.1.0
        def initialize(mapper, uri = nil)
          @mapper = mapper
          @uri    = uri
        end

        # Creates or updates a record in the database for the given entity.
        #
        # @param collection [Symbol] the target collection (it must be mapped).
        # @param entity [Object] the entity to persist
        #
        # @return [Object] the entity
        #
        # @since 0.1.0
        def persist(collection, entity)
          raise NotImplementedError
        end

        # Creates a record in the database for the given entity.
        # It should assign an id (identity) to the entity in case of success.
        #
        # @param collection [Symbol] the target collection (it must be mapped).
        # @param entity [Object] the entity to create
        #
        # @return [Object] the entity
        #
        # @since 0.1.0
        def create(collection, entity)
          raise NotImplementedError
        end

        # Updates a record in the database corresponding to the given entity.
        #
        # @param collection [Symbol] the target collection (it must be mapped).
        # @param entity [Object] the entity to update
        #
        # @return [Object] the entity
        #
        # @since 0.1.0
        def update(collection, entity)
          raise NotImplementedError
        end

        # Deletes a record in the database corresponding to the given entity.
        #
        # @param collection [Symbol] the target collection (it must be mapped).
        # @param entity [Object] the entity to delete
        #
        # @since 0.1.0
        def delete(collection, entity)
          raise NotImplementedError
        end

        # Returns all the records for the given collection
        #
        # @param collection [Symbol] the target collection (it must be mapped).
        #
        # @return [Array] all the records
        #
        # @since 0.1.0
        def all(collection)
          raise NotImplementedError
        end

        # Returns a unique record from the given collection, with the given
        # identity.
        #
        # @param collection [Symbol] the target collection (it must be mapped).
        # @param id [Object] the identity of the object.
        #
        # @return [Object] the entity
        #
        # @since 0.1.0
        def find(collection, id)
          raise NotImplementedError
        end

        # Returns the first record in the given collection.
        #
        # @param collection [Symbol] the target collection (it must be mapped).
        #
        # @return [Object] the first entity
        #
        # @since 0.1.0
        def first(collection)
          raise NotImplementedError
        end

        # Returns the last record in the given collection.
        #
        # @param collection [Symbol] the target collection (it must be mapped).
        #
        # @return [Object] the last entity
        #
        # @since 0.1.0
        def last(collection)
          raise NotImplementedError
        end

        # Empties the given collection.
        #
        # @param collection [Symbol] the target collection (it must be mapped).
        #
        # @since 0.1.0
        def clear(collection)
          raise NotImplementedError
        end

        # Executes a command for the given query.
        #
        # @param query [Object] the query object to act on.
        #
        # @since 0.1.0
        def command(query)
          raise NotImplementedError
        end

        # Returns a query
        #
        # @param collection [Symbol] the target collection (it must be mapped).
        # @param blk [Proc] a block of code to be executed in the context of
        #   the query.
        #
        # @return [Object]
        #
        # @since 0.1.0
        def query(collection, &blk)
          raise NotImplementedError
        end

        # Wraps the given block in a transaction.
        #
        # For performance reasons the block isn't in the signature of the method,
        # but it's yielded at the lower level.
        #
        # Please note that it's only supported by some databases.
        # For this reason, the options may vary from adapter to adapter.
        #
        # @param options [Hash] options for transaction
        #
        # @see Lotus::Model::Adapters::SqlAdapter#transaction
        # @see Lotus::Model::Adapters::MemoryAdapter#transaction
        #
        # @since 0.2.3
        def transaction(options = {})
          raise NotImplementedError
        end

        # Returns a string which can be executed to start a console suitable
        # for the configured database.
        #
        # @return [String] to be executed to start a database console
        #
        # @since 0.3.0
        def connection_string
          raise NotSupportedError
        end

        # Executes a raw statement directly on the connection
        #
        # @param raw [String] the raw statement to execute on the connection
        # @return [Object]
        #
        # @since 0.3.1
        def execute(raw)
          raise NotImplementedError
        end
      end
    end
  end
end
