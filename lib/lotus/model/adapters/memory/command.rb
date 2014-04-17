module Lotus
  module Model
    module Adapters
      module Memory
        # Execute a command for the given collection.
        #
        # @see Lotus::Model::Adapters::Memory::Collection
        # @see Lotus::Model::Mapping::Collection
        #
        # @api private
        # @since 0.1.0
        class Command
          # Initialize a command
          #
          # @param dataset [Lotus::Model::Adapters::Memory::Collection]
          # @param collection [Lotus::Model::Mapping::Collection]
          #
          # @api private
          # @since 0.1.0
          def initialize(dataset, collection)
            @dataset, @collection = dataset, collection
          end

          # Creates a record for the given entity.
          #
          # @param entity [Object] the entity to persist
          #
          # @see Lotus::Model::Adapters::Memory::Collection#insert
          #
          # @return the primary key of the just created record.
          #
          # @api private
          # @since 0.1.0
          def create(entity)
            @dataset.create(
              _serialize(entity)
            )
          end

          # Updates the corresponding record for the given entity.
          #
          # @param entity [Object] the entity to persist
          #
          # @see Lotus::Model::Adapters::Memory::Collection#update
          #
          # @api private
          # @since 0.1.0
          def update(entity)
            @dataset.update(
              _serialize(entity)
            )
          end

          # Deletes the corresponding record for the given entity.
          #
          # @param entity [Object] the entity to delete
          #
          # @see Lotus::Model::Adapters::Memory::Collection#delete
          #
          # @api private
          # @since 0.1.0
          def delete(entity)
            @dataset.delete(entity)
          end

          # Deletes all the records from the table.
          #
          # @see Lotus::Model::Adapters::Memory::Collection#clear
          #
          # @api private
          # @since 0.1.0
          def clear
            @dataset.clear
          end

          private
          # Serialize the given entity before to persist in the database.
          #
          # @return [Hash] the serialized entity
          #
          # @api private
          # @since 0.1.0
          def _serialize(entity)
            @collection.serialize(entity)
          end
        end
      end
    end
  end
end
