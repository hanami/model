require 'lotus/model/adapters/abstract'

module Lotus
  module Model
    module Adapters
      class Memory < Abstract
        def initialize
          @mutex = Mutex.new
          clear
        end

        def persist(entity)
          if entity.id
            update(entity)
          else
            create(entity)
          end
        end

        def create(entity)
          @mutex.synchronize do
            @current_id += 1
            entity.id = @current_id
            records[@current_id] = entity
          end
        end

        def update(entity)
          @mutex.synchronize { records[entity.id] = entity }
        end

        def delete(entity)
          @mutex.synchronize { records[entity.id] = nil }
        end

        def all
          @mutex.synchronize { records.values }
        end

        def find(id)
          @mutex.synchronize { records[id.to_i] unless id.nil? }
        end

        def first
          all.first
        end

        def last
          all.last
        end

        def clear
          @mutex.synchronize do
            @current_id = 0
            @records    = {}
          end
        end

        protected
        attr_reader :records
      end
    end
  end
end
