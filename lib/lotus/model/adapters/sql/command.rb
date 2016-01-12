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
          # @return the primary key of the just created record.
          #
          # @api private
          # @since 0.1.0
          def create(entity)
            _rescue_database_error do
              @collection.insert(entity)
            end
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
            _rescue_database_error do
              @collection.update(entity)
            end
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
            _rescue_database_error do
              @collection.delete
            end
          end

          alias_method :clear, :delete

          private

          # Rescues Sequel::DatabaseError in yielded block
          #
          # @api private
          def _rescue_database_error
            yield
          rescue Sequel::DatabaseError => e
            raise _transform_database_error(e)
          end

          # Transforms error into a Lotus::Model::Error
          #
          # @api private
          def _transform_database_error(error)
            case error
            when Sequel::CheckConstraintViolation
              Lotus::Model::CheckConstraintViolationError.new(error.message)
            when Sequel::ForeignKeyConstraintViolation
              Lotus::Model::ForeignKeyConstraintViolationError.new(error.message)
            when Sequel::NotNullConstraintViolation
              Lotus::Model::NotNullConstraintViolationError.new(error.message)
            when Sequel::UniqueConstraintViolation
              Lotus::Model::UniqueConstraintViolationError.new(error.message)
            else
              Lotus::Model::InvalidCommandError.new(error.message)
            end
          end
        end
      end
    end
  end
end

