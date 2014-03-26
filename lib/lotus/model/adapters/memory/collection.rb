require 'lotus/model/adapters/abstract'

module Lotus
  module Model
    module Adapters
      class Memory < Abstract
        class Collection
          attr_reader :name, :records

          def initialize(name)
            @name = name
            clear
          end

          def create(entity)
            @current_id += 1
            entity.id = @current_id
            records[@current_id] = entity
          end

          def update(entity)
            records[entity.id] = entity
          end

          def delete(entity)
            records[entity.id] = nil
          end

          def all
            records.values
          end

          def find(id)
            records[id] unless id.nil?
          end

          def first
            all.first
          end

          def clear
            @records    = {}
            @current_id = 0
          end
        end
      end
    end
  end
end
