require 'lotus/model/adapters/abstract'

module Lotus
  module Model
    module Adapters
      class Memory < Abstract
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

          attr_reader :name, :records

          def initialize(name)
            @name = name
            clear
          end

          def create(entity)
            @primary_key.increment! do |id|
              entity[:id] = id
              records[id] = entity
            end
          end

          def update(entity)
            records[entity.fetch(:id)] = entity
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
            @records     = {}
            @primary_key = PrimaryKey.new
          end
        end
      end
    end
  end
end
