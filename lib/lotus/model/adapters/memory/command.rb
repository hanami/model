module Lotus
  module Model
    module Adapters
      module Memory
        class Command
          def initialize(collection, mapper)
            @collection = collection
            @mapper     = mapper
          end

          def create(entity)
            @collection.create(
              _serialize(@collection.name, entity)
            )
          end

          def update(entity)
            @collection.update(
              _serialize(@collection.name, entity)
            )
          end

          def delete(entity)
            @collection.delete(entity)
          end

          def clear
            @collection.clear
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
