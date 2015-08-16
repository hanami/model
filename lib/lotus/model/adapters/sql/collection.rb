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
          #
          # @return [Lotus::Model::Adapters::Sql::Collection]
          #
          # @api private
          # @since 0.1.0
          def initialize(dataset, mapped_collection)
            super(dataset)
            @mapped_collection = mapped_collection
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
            Collection.new(super, @mapped_collection)
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
            Collection.new(super, @mapped_collection)
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
            Collection.new(super, @mapped_collection)
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
            Collection.new(super, @mapped_collection)
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
            Collection.new(super, @mapped_collection)
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
            Collection.new(super, @mapped_collection)
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
              Collection.new(super, @mapped_collection)
            end
          else
            def select(*args)
              Collection.new(__getobj__.select(*Lotus::Utils::Kernel.Array(args)), @mapped_collection)
            end
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
            Collection.new(super, @mapped_collection)
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
            @mapped_collection.deserialize(self)
          end

          # Select all attributes for current scope
          #
          # @return [Lotus::Model::Adapters::Sql::Collection] the filtered
          #   collection
          #
          # @see http://www.rubydoc.info/github/jeremyevans/sequel/Sequel%2FDataset%3Aselect_all
          #
          # @api private
          # @since x.x.x
          def select_all
            Collection.new(super(table_name), @mapped_collection)
          end

          # Use join table for current scope
          #
          # @return [Lotus::Model::Adapters::Sql::Collection] the filtered
          #   collection
          #
          # @see http://www.rubydoc.info/github/jeremyevans/sequel/Sequel%2FDataset%3Ajoin_table
          #
          # @api private
          # @since x.x.x
          def join_table(*args)
            Collection.new(super, @mapped_collection)
          end

          # Return table name mapped collection
          #
          # @return [String] table name
          #
          # @api private
          # @since x.x.x
          def table_name
            @mapped_collection.name
          end

          # Name of the identity column in database
          #
          # @return [Symbol] the identity name
          #
          # @api private
          # @since x.x.x
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
