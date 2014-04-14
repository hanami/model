module Lotus
  module Model
    module Adapters
      module Sql
        class Command
          def initialize(query)
            @collection = query.scoped
          end

          def create(entity)
            @collection.insert(entity)
          end

          def update(entity)
            @collection.update(entity)
          end

          def delete
            @collection.delete
          end

          alias_method :clear, :delete
        end
      end
    end
  end
end

