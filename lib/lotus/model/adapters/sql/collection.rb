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
          # @param mapper [Lotus::Model::Mapper] the mapper
          #
          # @return [Lotus::Model::Adapters::Sql::Collection]
          #
          # @api private
          # @since 0.1.0
          def initialize(dataset, mapper)
            super(dataset)
            @mapper = mapper
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
            Collection.new(super, @mapper)
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
            super _serialize(entity)
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
            Collection.new(super, @mapper)
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
            Collection.new(super, @mapper)
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
            Collection.new(super, @mapper)
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
            Collection.new(super, @mapper)
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
            Collection.new(super, @mapper)
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
              Collection.new(super, @mapper)
            end
          else
            def select(*args)
              Collection.new(__getobj__.select(*Lotus::Utils::Kernel.Array(args)), @mapper)
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
            Collection.new(super, @mapper)
          end

          def qualify(*args)
            Collection.new(super, @mapper)
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
            super _serialize(entity)
          end

          def graph(*args)
            Collection.new(super, @mapper)
          end

          # Resolves self by fetching the records from the database and
          # translating them into entities.
          #
          # @return [Array] the result of the query
          #
          # @api private
          # @since 0.1.0
          def to_a
            @mapper.deserialize(mapped, self, super)
          end

          def association(name)
            @mapper.collection(mapped).association(name)
          end

          def mapped
            first_source_table
          end

          def complex?
            joined_dataset?
          end

          private
          # Serialize the given entity before to persist in the database.
          #
          # @return [Hash] the serialized entity
          #
          # @api private
          # @since 0.1.0
          def _serialize(entity)
            @mapper.serialize(mapped, entity)
          end
        end
      end
    end
  end
end
