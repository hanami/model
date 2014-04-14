require 'delegate'

module Lotus
  module Model
    module Adapters
      module Sql
        class Collection < SimpleDelegator
          module Interface
            def name
              first_source_table
            end
          end

          def initialize(dataset, mapper)
            super(dataset)
            @mapper = mapper
          end

          def exclude(*args)
            Collection.new(super, @mapper)
          end

          def insert(entity)
            super _serialize(entity)
          end

          def limit(*args)
            Collection.new(super, @mapper)
          end

          def offset(*args)
            Collection.new(super, @mapper)
          end

          def or(*args)
            Collection.new(super, @mapper)
          end

          def order(*args)
            Collection.new(super, @mapper)
          end

          def select(*args)
            Collection.new(super, @mapper)
          end

          def where(*args)
            Collection.new(super, @mapper)
          end

          def update(entity)
            super _serialize(entity)
          end

          def to_a
            @mapper.deserialize(name, self)
          end

          private
          def _serialize(entity)
            @mapper.serialize(name, entity)
          end
        end
      end
    end
  end
end
