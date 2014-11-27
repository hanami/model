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
            self.class.new(super, @mapper)
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
            self.class.new(super, @mapper)
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
            self.class.new(super, @mapper)
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
            self.class.new(super, @mapper)
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
            self.class.new(super, @mapper)
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
            self.class.new(super, @mapper)
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
              self.class.new(super, @mapper)
            end
          else
            def select(*args)
              self.class.new(__getobj__.select(*Lotus::Utils::Kernel.Array(args)), @mapper)
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
            self.class.new(super, @mapper)
          end

          def qualify(*args)
            self.class.new(super, @mapper)
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

          def preload(*args)
            AssociationCollection.new(__getobj__.graph(*args), @mapper)
          end

          # Resolves self by fetching the records from the database and
          # translating them into entities.
          #
          # @return [Array] the result of the query
          #
          # @api private
          # @since 0.1.0
          def to_a
            _mapped_collection.deserialize(self)
          end

          def association(name)
            _mapped_collection.association(name)
          end

          def mapped
            first_source_table
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

          def _mapped_collection
            @mapper.collection(mapped)
          end
        end

        # @since x.x.x
        # @api private
        class AssociationCollection < Collection
          def to_a
            __getobj__.map do |record|
              _deserialize_associations(_entity(record), record)
            end
          end

          private
          def _entity(record)
            __deserialize(record.delete(mapped)).first
          end

          def _deserialize_associations(entity, record)
            record.each do |table_name, records|
              association = _mapped_collection.association(table_name)
              collection  = @mapper.collection(table_name)

              entities = __deserialize(records, collection)
              entities = entities.first if association.singular?

              entity.__send__(:"#{ association.name }=", entities)
            end

            entity
          end

          def __deserialize(records, collection = _mapped_collection)
            collection.deserialize([records])
          end
        end
      end
    end
  end
end
