require 'delegate'
require 'lotus/utils/kernel' unless RUBY_VERSION >= '2.1'

module Lotus
  module Model
    module Adapters
      module Sql
        # Maps a SQL database table and perfoms manipulations on it.
        #
        # @api private
        # @since 0.1.0
        #
        # @see http://sequel.jeremyevans.net/rdoc/files/doc/dataset_basics_rdoc.html
        # @see http://sequel.jeremyevans.net/rdoc/files/doc/dataset_filtering_rdoc.html
        class Collection < SimpleDelegator
          # Initialize a collection
          #
          # @param dataset [Sequel::Dataset] the dataset that maps a table or a
          #   subset of it.
          # @param mapped_collection [Lotus::Model::Mapping::Collection] a
          #   mapped collection
          # @param associations [Array] association symbols names to preload
          #
          # @return [Lotus::Model::Adapters::Sql::Collection]
          #
          # @api private
          # @since 0.1.0
          def initialize(dataset, mapped_collection, associations = [])
            super(dataset)
            @mapped_collection = mapped_collection
            @associations = associations
          end

          # Filters the current scope with an `exclude` directive.
          #
          # @param args [Array] the array of arguments
          #
          # @see Lotus::Model::Adapters::Sql::Query#exclude
          #
          # @return [Lotus::Model::Adapters::Sql::Collection] the filtered
          #   collection
          #
          # @api private
          # @since 0.1.0
          def exclude(*args)
            Collection.new(super, @mapped_collection, @associations)
          end

          # Creates a record for the given entity and assigns an id.
          #
          # @param entity [Object] the entity to persist
          #
          # @see Lotus::Model::Adapters::Sql::Command#create
          #
          # @return the primary key of the created record
          #
          # @api private
          # @since 0.1.0
          def insert(entity)
            serialized_entity            = _serialize(entity)
            serialized_entity[identity] = super(serialized_entity)

            _deserialize(serialized_entity)
          end

          # Filters the current scope with a `limit` directive.
          #
          # @param args [Array] the array of arguments
          #
          # @see Lotus::Model::Adapters::Sql::Query#limit
          #
          # @return [Lotus::Model::Adapters::Sql::Collection] the filtered
          #   collection
          #
          # @api private
          # @since 0.1.0
          def limit(*args)
            Collection.new(super, @mapped_collection, @associations)
          end

          # Filters the current scope with an `offset` directive.
          #
          # @param args [Array] the array of arguments
          #
          # @see Lotus::Model::Adapters::Sql::Query#offset
          #
          # @return [Lotus::Model::Adapters::Sql::Collection] the filtered
          #   collection
          #
          # @api private
          # @since 0.1.0
          def offset(*args)
            Collection.new(super, @mapped_collection, @associations)
          end

          # Filters the current scope with an `or` directive.
          #
          # @param args [Array] the array of arguments
          #
          # @see Lotus::Model::Adapters::Sql::Query#or
          #
          # @return [Lotus::Model::Adapters::Sql::Collection] the filtered
          #   collection
          #
          # @api private
          # @since 0.1.0
          def or(*args)
            Collection.new(super, @mapped_collection, @associations)
          end

          # Filters the current scope with an `order` directive.
          #
          # @param args [Array] the array of arguments
          #
          # @see Lotus::Model::Adapters::Sql::Query#order
          #
          # @return [Lotus::Model::Adapters::Sql::Collection] the filtered
          #   collection
          #
          # @api private
          # @since 0.1.0
          def order(*args)
            Collection.new(super, @mapped_collection, @associations)
          end

          # Filters the current scope with an `order` directive.
          #
          # @param args [Array] the array of arguments
          #
          # @see Lotus::Model::Adapters::Sql::Query#order
          #
          # @return [Lotus::Model::Adapters::Sql::Collection] the filtered
          #   collection
          #
          # @api private
          # @since 0.1.0
          def order_more(*args)
            Collection.new(super, @mapped_collection, @associations)
          end

          # Filters the current scope with a `select` directive.
          #
          # @param args [Array] the array of arguments
          #
          # @see Lotus::Model::Adapters::Sql::Query#select
          #
          # @return [Lotus::Model::Adapters::Sql::Collection] the filtered
          #   collection
          #
          # @api private
          # @since 0.1.0
          if RUBY_VERSION >= '2.1'
            def select(*args)
              Collection.new(super, @mapped_collection, @associations)
            end
          else
            def select(*args)
              Collection.new(__getobj__.select(*Lotus::Utils::Kernel.Array(args)), @mapped_collection, @associations)
            end
          end


          # Filters the current scope with a `group` directive.
          #
          # @param args [Array] the array of arguments
          #
          # @see Lotus::Model::Adapters::Sql::Query#group
          #
          # @return [Lotus::Model::Adapters::Sql::Collection] the filtered
          #   collection
          #
          # @api private
          # @since 0.5.0
          def group(*args)
            Collection.new(super, @mapped_collection, @associations)
          end

          # Filters the current scope with a `where` directive.
          #
          # @param args [Array] the array of arguments
          #
          # @see Lotus::Model::Adapters::Sql::Query#where
          #
          # @return [Lotus::Model::Adapters::Sql::Collection] the filtered
          #   collection
          #
          # @api private
          # @since 0.1.0
          def where(*args)
            Collection.new(super, @mapped_collection, @associations)
          end

          # Updates the record corresponding to the given entity.
          #
          # @param entity [Object] the entity to persist
          #
          # @see Lotus::Model::Adapters::Sql::Command#update
          #
          # @api private
          # @since 0.1.0
          def update(entity)
            serialized_entity = _serialize(entity)
            super(serialized_entity)

            _deserialize(serialized_entity)
          end

          # Resolves self by fetching the records from the database and
          # translating them into entities.
          #
          # @return [Array] the result of the query
          #
          # @api private
          # @since 0.1.0
          def to_a
            @mapped_collection.deserialize(self, @associations)
          end

          # Preload a given association into root's aggregation
          # This should be implemented inside Repository in a class method. See example below.
          #
          # @since x.x.x
          # @return Lotus::Model::Adapters::Sql::Collection
          #
          # @example
          #
          #     mapping do
          #       collections :users do
          #         entity User
          #         attribute :id, Integer
          #         association :articles, [Article], foreign_key: :user_id, collection: :articles
          #       end
          #
          #       collections :articles do
          #         entity Article
          #         attribute :id, Integer
          #         attribute :user_id, Integer
          #         association :user, User, foreign_key: :id, collection: :articles
          #       end
          #     end
          #
          #      class UserRepository
          #        include Lotus::Repository
          #
          #       def with_articles
          #         query.preload(:articles)
          #       end
          #     end
          def preload(association)
            @associations << association
            self
          end

          # Select all attributes for current scope
          #
          # @return [Lotus::Model::Adapters::Sql::Collection] the filtered
          #   collection
          #
          # @api private
          # @since 0.5.0
          #
          # @see http://www.rubydoc.info/github/jeremyevans/sequel/Sequel%2FDataset%3Aselect_all
          def select_all
            Collection.new(super(table_name), @mapped_collection, @associations)
          end

          # Use join table for current scope
          #
          # @return [Lotus::Model::Adapters::Sql::Collection] the filtered
          #   collection
          #
          # @api private
          # @since 0.5.0
          #
          # @see http://www.rubydoc.info/github/jeremyevans/sequel/Sequel%2FDataset%3Ajoin_table
          def join_table(*args)
            Collection.new(super, @mapped_collection, @associations)
          end

          # Return table name mapped collection
          #
          # @return [String] table name
          #
          # @api private
          # @since 0.5.0
          def table_name
            @mapped_collection.name
          end

          # Name of the identity column in database
          #
          # @return [Symbol] the identity name
          #
          # @api private
          # @since 0.5.0
          def identity
            @mapped_collection.identity
          end

          private
          # Serialize the given entity before to persist in the database.
          #
          # @return [Hash] the serialized entity
          #
          # @api private
          # @since 0.1.0
          def _serialize(entity)
            @mapped_collection.serialize(entity)
          end

          # Deserialize the given entity after it was persisted in the database.
          #
          # @return [Lotus::Entity] the deserialized entity
          #
          # @api private
          # @since 0.2.2
          def _deserialize(entity)
            @mapped_collection.deserialize([entity]).first
          end
        end
      end
    end
  end
end
