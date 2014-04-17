module Lotus
  module Model
    module Adapters
      module Sql
        # Execute a command for the given query.
        #
        # @see Lotus::Model::Adapters::Sql::Query
        #
        # @api private
        # @since 0.1.0
        class Command
          # Initialize a command
          #
          # @param query [Lotus::Model::Adapters::Sql::Query]
          #
          # @api private
          # @since 0.1.0
          def initialize(query)
            @collection = query.scoped
          end

          # Creates a record for the given entity.
          #
          # @param entity [Object] the entity to persist
          #
          # @see Lotus::Model::Adapters::Sql::Collection#insert
          #
          # @return the primary key of the just created object.
          #
          # @api private
          # @since 0.1.0
          def create(entity)
            @collection.insert(entity)
          end

          # Updates the corresponding record for the given entity.
          #
          # @param entity [Object] the entity to persist
          #
          # @see Lotus::Model::Adapters::Sql::Collection#update
          #
          # @api private
          # @since 0.1.0
          def update(entity)
            @collection.update(entity)
          end

          # Deletes all the records for the current query.
          #
          # It's used to delete a single record or an entire database table.
          #
          # @see Lotus::Model::Adapters::SqlAdapter#delete
          # @see Lotus::Model::Adapters::SqlAdapter#clear
          #
          # @api private
          # @since 0.1.0
          def delete
            @collection.delete
          end

          alias_method :clear, :delete
        end
      end
    end
  end
end

