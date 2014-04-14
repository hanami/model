module Lotus
  module Model
    module Adapters
      module Sql
        class Command
          def initialize(collection, mapper)
            @collection = collection
            @mapper     = mapper
          end

          def create(entity)
            @collection.insert(
              _serialize(@collection.name, entity)
            )
          end

          def update(entity, key)
            @collection.where(key => entity.id).update(
              _serialize(@collection.name, entity)
            )
          end

          def delete(entity, key)
            @collection.where(key => entity.id)
              .delete
          end

          def clear
            @collection.delete
          end

          private
          def _serialize(collection, entity)
            @mapper.serialize(collection, entity)
          end
        end
      end
    end
  end
end

