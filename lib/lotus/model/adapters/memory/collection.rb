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

          # TODO extract into another file
          class Query
            attr_reader :conditions

            def initialize(collection)
              @collection = collection
              @conditions = []
            end

            def where(condition)
              column, value = *Array(condition).flatten
              conditions.push(Proc.new{ find_all{|r| r.fetch(column) == value} })
              self
            end

            alias_method :and, :where

            def order(column)
              conditions.push(Proc.new{ sort_by{|r| r.fetch(column)} })
              self
            end

            # def all(records = @collection.all)
            #   conditions.map do |condition|
            #     records.instance_exec(&condition)
            #     # @collection.all.instance_exec(&condition)
            #   end
            # end
            def all
              @conditions.map do |condition|
                @collection.all.instance_exec(&condition)
              end
            end
          end

          def where(condition)
            query.where(condition)
          end

          def order(column)
            query.order(column)
          end

          private
          def query
            Query.new(self)
          end
        end
      end
    end
  end
end
