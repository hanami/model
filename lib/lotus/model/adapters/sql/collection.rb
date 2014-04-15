require 'delegate'

module Lotus
  module Model
    module Adapters
      module Sql
        class Collection < SimpleDelegator
          def initialize(dataset, collection)
            super(dataset)
            @collection = collection
          end

          def exclude(*args)
            Collection.new(super, @collection)
          end

          def insert(entity)
            super _serialize(entity)
          end

          def limit(*args)
            Collection.new(super, @collection)
          end

          def offset(*args)
            Collection.new(super, @collection)
          end

          def or(*args)
            Collection.new(super, @collection)
          end

          def order(*args)
            Collection.new(super, @collection)
          end

          def select(*args)
            Collection.new(super, @collection)
          end

          def where(*args)
            Collection.new(super, @collection)
          end

          def update(entity)
            super _serialize(entity)
          end

          def to_a
            @collection.deserialize(self)
          end

          private
          def _serialize(entity)
            @collection.serialize(entity)
          end
        end
      end
    end
  end
end
