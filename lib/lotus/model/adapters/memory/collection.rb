module Lotus
  module Model
    module Adapters
      module Memory
        class Collection
          class PrimaryKey
            def initialize
              @current = 0
            end

            def increment!
              yield(@current += 1)
              @current
            end
          end

          attr_reader :name, :key, :records

          def initialize(name, key)
            @name, @key = name, key
            clear
          end

          def create(entity)
            @primary_key.increment! do |id|
              entity[key] = id
              records[id] = entity
            end
          end

          def update(entity)
            records[entity.fetch(key)] = entity
          end

          def delete(entity)
            records.delete(entity.id)
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
            @records     = {}
            @primary_key = PrimaryKey.new
          end
        end
      end
    end
  end
end
