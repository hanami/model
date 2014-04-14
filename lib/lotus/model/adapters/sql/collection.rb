module Lotus
  module Model
    module Adapters
      module Sql
        module Collection
          def name
            first_source_table
          end
        end
      end
    end
  end
end
