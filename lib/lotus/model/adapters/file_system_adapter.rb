require 'thread'
require 'pathname'
require 'lotus/model/adapters/memory_adapter'

module Lotus
  module Model
    module Adapters
      # In memory adapter with file system persistence.
      # It behaves like the SQL adapter, but it doesn't support all the SQL
      # features offered by that kind of databases.
      #
      # This adapter SHOULD be used only for development or testing purposes.
      # Each read/write operation is wrapped by a `Mutex` and persisted to the
      # disk.
      #
      # For those reasons it's really unefficient, but great for quick
      # prototyping as it's schema-less.
      #
      # It works exactly like the `MemoryAdapter`, with the only difference
      # that it persist data to the disk.
      #
      # The persistence policy uses Ruby `Marshal` `dump` and `load` operations.
      # Please be aware of the limitations this model.
      #
      # @see Lotus::Model::Adapters::Implementation
      # @see Lotus::Model::Adapters::MemoryAdapter
      # @see http://www.ruby-doc.org/core/Marshal.html
      #
      # @api private
      # @since x.x.x
      class FileSystemAdapter < MemoryAdapter
        # Default writing mode
        #
        # Binary, write only, create file if missing or erase if don't.
        #
        # @see http://ruby-doc.org/core/File/Constants.html
        #
        # @since x.x.x
        # @api private
        WRITING_MODE = File::WRONLY|File::BINARY|File::CREAT

        # Default chmod
        #
        # @see http://en.wikipedia.org/wiki/Chmod
        #
        # @since x.x.x
        # @api private
        CHMOD        = 0644

        # File scheme
        #
        # @see https://tools.ietf.org/html/rfc3986
        #
        # @since x.x.x
        # @api private
        FILE_SCHEME  = 'file:///'.freeze

        # Initialize the adapter.
        #
        # @param mapper [Object] the database mapper
        # @param uri [String] the connection uri
        #
        # @return [Lotus::Model::Adapters::FileSystemAdapter]
        #
        # @see Lotus::Model::Mapper
        #
        # @api private
        # @since x.x.x
        def initialize(mapper, uri)
          super
          prepare(uri)

          @_mutex = Mutex.new
        end

        # Returns all the records for the given collection
        #
        # @param collection [Symbol] the target collection (it must be mapped).
        #
        # @return [Array] all the records
        #
        # @api private
        # @since x.x.x
        def all(collection)
          _synchronize do
            read(collection)
            super
          end
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
        # @since x.x.x
        def find(collection, id)
          _synchronize do
            read(collection)
            super
          end
        end

        # Returns the first record in the given collection.
        #
        # @param collection [Symbol] the target collection (it must be mapped).
        #
        # @return [Object] the first entity
        #
        # @api private
        # @since x.x.x
        def first(collection)
          _synchronize do
            read(collection)
            super
          end
        end

        # Returns the last record in the given collection.
        #
        # @param collection [Symbol] the target collection (it must be mapped).
        #
        # @return [Object] the last entity
        #
        # @api private
        # @since x.x.x
        def last(collection)
          _synchronize do
            read(collection)
            super
          end
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
        # @since x.x.x
        def create(collection, entity)
          _synchronize do
            super
            write(collection)
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
        # @since x.x.x
        def update(collection, entity)
          _synchronize do
            super
            write(collection)
          end
        end

        # Deletes a record in the database corresponding to the given entity.
        #
        # @param collection [Symbol] the target collection (it must be mapped).
        # @param entity [#id] the entity to delete
        #
        # @api private
        # @since x.x.x
        def delete(collection, entity)
          _synchronize do
            super
            write(collection)
          end
        end

        # Deletes all the records from the given collection and resets the
        # identity counter.
        #
        # @param collection [Symbol] the target collection (it must be mapped).
        #
        # @api private
        # @since x.x.x
        def clear(collection)
          _synchronize do
            super
            write(collection)
          end
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
        # @since x.x.x
        def query(collection, context = nil, &blk)
          # _synchronize do
            read(collection)
            super
          # end
        end

        # Database informations
        #
        # @return [Hash] per collection informations
        #
        # @api private
        # @since x.x.x
        def info
          @collections.each_with_object({}) do |(collection,_), result|
            result[collection] = query(collection).count
          end
        end

        private
        # @api private
        # @since x.x.x
        def prepare(uri)
          @root = Pathname.new(uri.sub(FILE_SCHEME, ''))
          @root.mkpath
        end

        # @api private
        # @since x.x.x
        def _synchronize
          @_mutex.synchronize { yield }
        end

        # @api private
        # @since x.x.x
        def write(collection)
          path = @root.join("#{ collection }")
          path.open(WRITING_MODE, CHMOD) {|f| f.write _dump( @collections.fetch(collection) ) }
        end

        # @api private
        # @since x.x.x
        def read(collection)
          path = @root.join("#{ collection }")
          @collections[collection] = _load(path.read) if path.exist?
        end

        # @api private
        # @since x.x.x
        def _dump(contents)
          Marshal.dump(contents)
        end

        # @api private
        # @since x.x.x
        def _load(contents)
          Marshal.load(contents)
        end
      end
    end
  end
end
