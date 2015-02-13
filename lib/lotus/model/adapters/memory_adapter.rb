require 'lotus/model/adapters/abstract'
require 'lotus/model/adapters/implementation'
require 'lotus/model/adapters/memory/collection'
require 'lotus/model/adapters/memory/command'
require 'lotus/model/adapters/memory/query'

module Lotus
  module Model
    module Adapters
      # In memory adapter that behaves like a SQL database.
      # Not all the features of the SQL adapter are supported.
      #
      # This adapter SHOULD be used only for development or testing purposes,
      # because its computations are inefficient and the data is volatile.
      #
      # @see Lotus::Model::Adapters::Implementation
      #
      # @api private
      # @since 0.1.0
      class MemoryAdapter < Abstract
        include Implementation

        # Initialize the adapter.
        #
        # @param mapper [Object] the database mapper
        # @param uri [String] the connection uri (ignored)
        #
        # @return [Lotus::Model::Adapters::MemoryAdapter]
        #
        # @see Lotus::Model::Mapper
        #
        # @api private
        # @since 0.1.0
        def initialize(mapper, uri = nil)
          super

          @mutex       = Mutex.new
          @collections = {}
        end

        # Creates a record in the database for the given entity.
        # It assigns the `id` attribute, in case of success.
        #
        # @param collection [Symbol] the target collection (it must be mapped).
        # @param entity [#id=] the entity to create
        #
        # @return [Object] the entity
        #
        # @api private
        # @since 0.1.0
        def create(collection, entity)
          synchronize do
            command(collection).create(entity)
          end
        end

        # Updates a record in the database corresponding to the given entity.
        #
        # @param collection [Symbol] the target collection (it must be mapped).
        # @param entity [#id] the entity to update
        #
        # @return [Object] the entity
        #
        # @api private
        # @since 0.1.0
        def update(collection, entity)
          synchronize do
            command(collection).update(entity)
          end
        end

        # Deletes a record in the database corresponding to the given entity.
        #
        # @param collection [Symbol] the target collection (it must be mapped).
        # @param entity [#id] the entity to delete
        #
        # @api private
        # @since 0.1.0
        def delete(collection, entity)
          synchronize do
            command(collection).delete(entity)
          end
        end

        # Deletes all the records from the given collection and resets the
        # identity counter.
        #
        # @param collection [Symbol] the target collection (it must be mapped).
        #
        # @api private
        # @since 0.1.0
        def clear(collection)
          synchronize do
            command(collection).clear
          end
        end

        # Fabricates a command for the given query.
        #
        # @param collection [Symbol] the collection name (it must be mapped)
        #
        # @return [Lotus::Model::Adapters::Memory::Command]
        #
        # @see Lotus::Model::Adapters::Memory::Command
        #
        # @api private
        # @since 0.1.0
        def command(collection)
          Memory::Command.new(_collection(collection), _mapped_collection(collection))
        end

        # Fabricates a query
        #
        # @param collection [Symbol] the target collection (it must be mapped).
        # @param blk [Proc] a block of code to be executed in the context of
        #   the query.
        #
        # @return [Lotus::Model::Adapters::Memory::Query]
        #
        # @see Lotus::Model::Adapters::Memory::Query
        #
        # @api private
        # @since 0.1.0
        def query(collection, context = nil, &blk)
          synchronize do
            Memory::Query.new(_collection(collection), _mapped_collection(collection), &blk)
          end
        end

        # WARNING: this is a no-op. For "real" transactions please use
        # `SqlAdapter` or another adapter that supports them
        #
        # @param options [Hash] options for transaction
        #
        # @see Lotus::Model::Adapters::SqlAdapter#transaction
        # @see Lotus::Model::Adapters::Abstract#transaction
        #
        # @since 0.2.3
        def transaction(options = {})
          yield
        end

        private

        # Returns a collection from the given name.
        #
        # @param name [Symbol] a name of the collection (it must be mapped).
        #
        # @return [Lotus::Model::Adapters::Memory::Collection]
        #
        # @see Lotus::Model::Adapters::Memory::Collection
        #
        # @api private
        # @since 0.1.0
        def _collection(name)
          @collections[name] ||= Memory::Collection.new(name, _identity(name))
        end

        # Executes the given block within a critical section.
        #
        # @api private
        # @since 0.2.0
        def synchronize
          @mutex.synchronize { yield }
        end
      end
    end
  end
end
