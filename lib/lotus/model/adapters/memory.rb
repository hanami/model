require 'lotus/model/adapters/abstract'

module Lotus
  module Model
    module Adapters
      class Memory < Abstract
        def initialize
          @current_id = 0
          @records    = {}
        end

        def persist(object)
          if object.send(:id)
            update(object)
          else
            create(object)
          end
        end

        def create(object)
          @current_id += 1
          object.send(:id=, @current_id)
          records[@current_id] = object
        end

        def update(object)
          records[object.send(:id)] = object
        end

        def delete(object)
          records[object.send(:id)] = nil
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
