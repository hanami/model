module Hanami
  module Model
    module Adapters
      module Memory
        # Execute a command for the given collection.
        #
        # @see Hanami::Model::Adapters::Memory::Collection
        # @see Hanami::Model::Mapping::Collection
        #
        # @api private
        # @since 0.1.0
        class Command
          # Initialize a command
          #
          # @param dataset [Hanami::Model::Adapters::Memory::Collection]
          # @param collection [Hanami::Model::Mapping::Collection]
          #
          # @api private
          # @since 0.1.0
          def initialize(dataset, collection)
            @dataset    = dataset
            @collection = collection
          end

          # Creates a record for the given entity.
          #
          # @param entity [Object] the entity to persist
          #
          # @see Hanami::Model::Adapters::Memory::Collection#insert
          #
          # @return the primary key of the just created record.
          #
          # @api private
          # @since 0.1.0
          def create(entity)
            serialized_entity            = _serialize(entity)
            serialized_entity[_identity] = @dataset.create(serialized_entity)

            _deserialize(serialized_entity)
          end

          # Updates the corresponding record for the given entity.
          #
          # @param entity [Object] the entity to persist
          #
          # @see Hanami::Model::Adapters::Memory::Collection#update
          #
          # @api private
          # @since 0.1.0
          def update(entity)
            serialized_entity = _serialize(entity)
            @dataset.update(serialized_entity)

            _deserialize(serialized_entity)
          end

          # Deletes the corresponding record for the given entity.
          #
          # @param entity [Object] the entity to delete
          #
          # @see Hanami::Model::Adapters::Memory::Collection#delete
          #
          # @api private
          # @since 0.1.0
          def delete(entity)
            @dataset.delete(entity)
          end

          # Deletes all the records from the table.
          #
          # @see Hanami::Model::Adapters::Memory::Collection#clear
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

          # Deserialize the given entity after it was persisted in the database.
          #
          # @return [Hanami::Entity] the deserialized entity
          #
          # @api private
          # @since 0.2.2
          def _deserialize(entity)
            @collection.deserialize([entity]).first
          end

          # Name of the identity column in database
          #
          # @return [Symbol] the identity name
          #
          # @api private
          # @since 0.2.2
          def _identity
            @collection.identity
          end
        end
      end
    end
  end
end
