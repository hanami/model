module Hanami
  module Model
    module Adapters
      module Sql
        # Execute a command for the given query.
        #
        # @see Hanami::Model::Adapters::Sql::Query
        #
        # @api private
        # @since 0.1.0
        class Command
          # Initialize a command
          #
          # @param query [Hanami::Model::Adapters::Sql::Query]
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
          # @see Hanami::Model::Adapters::Sql::Collection#insert
          #
          # @return the primary key of the just created record.
          #
          # @api private
          # @since 0.1.0
          def create(entity)
            _handle_database_error { @collection.insert(entity) }
          end

          # Updates the corresponding record for the given entity.
          #
          # @param entity [Object] the entity to persist
          #
          # @see Hanami::Model::Adapters::Sql::Collection#update
          #
          # @api private
          # @since 0.1.0
          def update(entity)
            _handle_database_error { @collection.update(entity) }
          end

          # Deletes all the records for the current query.
          #
          # It's used to delete a single record or an entire database table.
          #
          # @see Hanami::Model::Adapters::SqlAdapter#delete
          # @see Hanami::Model::Adapters::SqlAdapter#clear
          #
          # @api private
          # @since 0.1.0
          def delete
            _handle_database_error { @collection.delete }
          end

          alias_method :clear, :delete

          private

          # Handles any possible Adapter's Database Error
          #
          # @api private
          # @since x.x.x
          def _handle_database_error
            yield
          rescue Sequel::DatabaseError => e
            raise _mapping_sequel_to_model(e)
          end

          # Maps SQL Adapter Violation's Errors into Hanami::Model Specific Errors
          #
          # @param adapter error [Object]
          #
          # @api private
          # @since x.x.x
          def _mapping_sequel_to_model(error)
            case error
            when Sequel::CheckConstraintViolation
              Hanami::Model::CheckConstraintViolationError
            when Sequel::ForeignKeyConstraintViolation
              Hanami::Model::ForeignKeyConstraintViolationError
            when Sequel::NotNullConstraintViolation
              Hanami::Model::NotNullConstraintViolationError
            when Sequel::UniqueConstraintViolation
              Hanami::Model::UniqueConstraintViolationError
            else
              Hanami::Model::InvalidCommandError
            end.new(error.message)
          end
        end
      end
    end
  end
end
