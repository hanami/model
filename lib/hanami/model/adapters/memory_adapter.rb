require 'hanami/model/adapters/abstract'
require 'hanami/model/adapters/implementation'
require 'hanami/model/adapters/memory/collection'
require 'hanami/model/adapters/memory/command'
require 'hanami/model/adapters/memory/query'

module Hanami
  module Model
    module Adapters
      # In memory adapter that behaves like a SQL database.
      # Not all the features of the SQL adapter are supported.
      #
      # This adapter SHOULD be used only for development or testing purposes,
      # because its computations are inefficient and the data is volatile.
      #
      # @see Hanami::Model::Adapters::Implementation
      #
      # @api private
      # @since 0.1.0
      class MemoryAdapter < Abstract
        include Implementation

        # Initialize the adapter.
        #
        # @param mapper [Object] the database mapper
        # @param uri [String] the connection uri (ignored)
        # @param options [Hash] a hash of non mandatory adapter options
        #
        # @return [Hanami::Model::Adapters::MemoryAdapter]
        #
        # @see Hanami::Model::Mapper
        #
        # @api private
        # @since 0.1.0
        def initialize(mapper, uri = nil, options = {})
          super

          @mutex       = Mutex.new
          @collections = {}
        end

        # Creates a record in the database for the given attributes.
        # It assigns the `id` attribute, in case of success.
        #
        # @param collection [Symbol] the target collection (it must be mapped).
        # @param attributes [#id=] the attributes to create
        #
        # @return [Object] the entity
        #
        # @api private
        # @since 0.1.0
        def create(collection, attributes)
          synchronize do
            command(collection).create(attributes)
          end
        end

        # Updates a record in the database corresponding to the given attributes.
        #
        # @param collection [Symbol] the target collection (it must be mapped).
        # @param attributes [#id] the attributes to update
        #
        # @return [Object] the entity
        #
        # @api private
        # @since 0.1.0
        def update(collection, attributes)
          synchronize do
            command(collection).update(attributes)
          end
        end

        # Deletes a record in the database corresponding to the given attributes.
        #
        # @param collection [Symbol] the target collection (it must be mapped).
        # @param attributes [#id] the attributes to delete
        #
        # @api private
        # @since 0.1.0
        def delete(collection, attributes)
          synchronize do
            command(collection).delete(attributes)
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
        # @return [Hanami::Model::Adapters::Memory::Command]
        #
        # @see Hanami::Model::Adapters::Memory::Command
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
        # @return [Hanami::Model::Adapters::Memory::Query]
        #
        # @see Hanami::Model::Adapters::Memory::Query
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
        # @see Hanami::Model::Adapters::SqlAdapter#transaction
        # @see Hanami::Model::Adapters::Abstract#transaction
        #
        # @since 0.2.3
        def transaction(options = {})
          yield
        end

        # @api private
        # @since 0.5.0
        #
        # @see Hanami::Model::Adapters::Abstract#disconnect
        def disconnect
          @collections = DisconnectedResource.new
          @mutex       = DisconnectedResource.new
        end

        private

        # Returns a collection from the given name.
        #
        # @param name [Symbol] a name of the collection (it must be mapped).
        #
        # @return [Hanami::Model::Adapters::Memory::Collection]
        #
        # @see Hanami::Model::Adapters::Memory::Collection
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
