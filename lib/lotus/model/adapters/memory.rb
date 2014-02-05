require 'lotus/model/adapters/abstract'

module Lotus
  module Model
    module Adapters
      class Memory < Abstract
        def initialize
          @current_id = 0
          @records    = {}
        end

        def persist(entity)
          if entity.send(:id)
            update(entity)
          else
            create(entity)
          end
        end

        def create(entity)
          @current_id += 1
          entity.send(:id=, @current_id)
          records[@current_id] = entity
        end

        def update(entity)
          records[entity.send(:id)] = entity
        end

        def delete(entity)
          records[entity.send(:id)] = nil
        end

        def all
          records.values
        end

        def find(id)
          records[id]
        end

        def first
          all.first
        end

        def last
          all.last
        end

        def clear
          records.clear
        end

        protected
        attr_reader :records
      end
    end
  end
end
