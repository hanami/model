require 'lotus/model/adapters/abstract'
require 'lotus/model/adapters/implementation'
require 'lotus/model/adapters/sql/collection'
require 'lotus/model/adapters/sql/command'
require 'lotus/model/adapters/sql/query'
require 'lotus/model/adapters/sql/console'
require 'sequel'

module Lotus
  module Model
    module Adapters
      # Adapter for SQL databases
      #
      # In order to use it with a specific database, you must require the Ruby
      # gem before of loading Lotus::Model.
      #
      # @see Lotus::Model::Adapters::Implementation
      #
      # @api private
      # @since 0.1.0
      class SqlAdapter < Abstract
        include Implementation

        # Initialize the adapter.
        #
        # Lotus::Model uses Sequel. For a complete reference of the connection
        # URI, please see: http://sequel.jeremyevans.net/rdoc/files/doc/opening_databases_rdoc.html
        #
        # @param mapper [Object] the database mapper
        # @param uri [String] the connection uri for the database
        #
        # @return [Lotus::Model::Adapters::SqlAdapter]
        #
        # @raise [Lotus::Model::Adapters::DatabaseAdapterNotFound] if the given
        #   URI refers to an unknown or not registered adapter.
        #
        # @raise [URI::InvalidURIError] if the given URI is malformed
        #
        # @see Lotus::Model::Mapper
        # @see http://sequel.jeremyevans.net/rdoc/files/doc/opening_databases_rdoc.html
        #
        # @api private
        # @since 0.1.0
        def initialize(mapper, uri)
          super
          @connection = Sequel.connect(@uri)
        rescue Sequel::AdapterNotFound => e
          raise DatabaseAdapterNotFound.new(e.message)
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
          command(
            query(collection)
          ).create(entity)
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
          command(
            _find(collection, entity.id)
          ).update(entity)
        end

        # Deletes a record in the database corresponding to the given entity.
        #
        # @param collection [Symbol] the target collection (it must be mapped).
        # @param entity [#id] the entity to delete
        #
        # @api private
        # @since 0.1.0
        def delete(collection, entity)
          command(
            _find(collection, entity.id)
          ).delete
        end

        # Deletes all the records from the given collection.
        #
        # @param collection [Symbol] the target collection (it must be mapped).
        #
        # @api private
        # @since 0.1.0
        def clear(collection)
          command(query(collection)).clear
        end

        # Fabricates a command for the given query.
        #
        # @param query [Lotus::Model::Adapters::Sql::Query] the query object to
        #   act on.
        #
        # @return [Lotus::Model::Adapters::Sql::Command]
        #
        # @see Lotus::Model::Adapters::Sql::Command
        #
        # @api private
        # @since 0.1.0
        def command(query)
          Sql::Command.new(query)
        end

        # Fabricates a query
        #
        # @param collection [Symbol] the target collection (it must be mapped).
        # @param blk [Proc] a block of code to be executed in the context of
        #   the query.
        #
        # @return [Lotus::Model::Adapters::Sql::Query]
        #
        # @see Lotus::Model::Adapters::Sql::Query
        #
        # @api private
        # @since 0.1.0
        def query(collection, context = nil, &blk)
          Sql::Query.new(_collection(collection), context, &blk)
        end

        # Wraps the given block in a transaction.
        #
        # For performance reasons the block isn't in the signature of the method,
        # but it's yielded at the lower level.
        #
        # @param options [Hash] options for transaction
        # @option rollback [Symbol] the optional rollback policy: `:always` or
        #   `:reraise`.
        #
        # @see Lotus::Repository::ClassMethods#transaction
        #
        # @since 0.2.3
        # @api private
        #
        # @example Basic usage
        #   require 'lotus/model'
        #
        #   class Article
        #     include Lotus::Entity
        #     attributes :title, :body
        #   end
        #
        #   class ArticleRepository
        #     include Lotus::Repository
        #   end
        #
        #   article = Article.new(title: 'Introducing transactions',
        #     body: 'lorem ipsum')
        #
        #   ArticleRepository.transaction do
        #     ArticleRepository.dangerous_operation!(article) # => RuntimeError
        #     # !!! ROLLBACK !!!
        #   end
        #
        # @example Policy rollback always
        #   require 'lotus/model'
        #
        #   class Article
        #     include Lotus::Entity
        #     attributes :title, :body
        #   end
        #
        #   class ArticleRepository
        #     include Lotus::Repository
        #   end
        #
        #   article = Article.new(title: 'Introducing transactions',
        #     body: 'lorem ipsum')
        #
        #   ArticleRepository.transaction(rollback: :always) do
        #     ArticleRepository.create(article)
        #     # !!! ROLLBACK !!!
        #   end
        #
        #   # The operation is rolled back, even in no exceptions were raised.
        #
        # @example Policy rollback reraise
        #   require 'lotus/model'
        #
        #   class Article
        #     include Lotus::Entity
        #     attributes :title, :body
        #   end
        #
        #   class ArticleRepository
        #     include Lotus::Repository
        #   end
        #
        #   article = Article.new(title: 'Introducing transactions',
        #     body: 'lorem ipsum')
        #
        #   ArticleRepository.transaction(rollback: :reraise) do
        #     ArticleRepository.dangerous_operation!(article) # => RuntimeError
        #     # !!! ROLLBACK !!!
        #   end # => RuntimeError
        #
        #   # The operation is rolled back, but RuntimeError is re-raised.
        def transaction(options = {})
          @connection.transaction(options) do
            yield
          end
        end

        # Returns a string which can be executed to start a console suitable
        # for the configured database, adding the necessary CLI flags, such as
        # url, password, port number etc.
        #
        # @return [String]
        #
        # @since 0.3.0
        def connection_string
          Sql::Console.new(@uri).connection_string
        end

        # Executes raw sql directly on the connection
        #
        # @param raw [String] the raw sql statement to execute on the connection
        #
        # @return [Object]
        #
        # @raise [Lotus::Model::InvalidQueryError] if raw statement is invalid
        #
        # @since 0.3.1
        def execute(raw)
          begin
            @connection.execute(raw)
          rescue Sequel::DatabaseError => e
            raise Lotus::Model::InvalidQueryError.new(e.message)
          end
        end

        private

        # Returns a collection from the given name.
        #
        # @param name [Symbol] a name of the collection (it must be mapped).
        #
        # @return [Lotus::Model::Adapters::Sql::Collection]
        #
        # @see Lotus::Model::Adapters::Sql::Collection
        #
        # @api private
        # @since 0.1.0
        def _collection(name)
          Sql::Collection.new(@connection[name], _mapped_collection(name))
        end
      end
    end
  end
end
