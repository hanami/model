module Lotus
  module Model
    module Adapters
      module Sql
        class Command
          def initialize(query, mapper)
            @collection = query.scoped
            @mapper     = mapper
          end

          def create(entity)
            @collection.insert(
              _serialize(entity)
            )
          end

          def update(entity)
            @collection.update(
              _serialize(entity)
            )
          end

          def delete
            @collection.delete
          end

          alias_method :clear, :delete

          private
          def _serialize(entity)
            @mapper.serialize(@collection.name, entity)
          end
        end
      end
    end
  end
end

