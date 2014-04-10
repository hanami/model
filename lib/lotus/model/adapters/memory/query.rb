require 'lotus/model/adapters/abstract'

module Lotus
  module Model
    module Adapters
      class Memory < Abstract
        class Query
          attr_reader :conditions, :modifiers

          def initialize(collection)
            @collection = collection
            @conditions = []
            @modifiers  = []
          end

          def where(condition)
            column, value = *Array(condition).flatten
            conditions.push(Proc.new{ find_all{|r| r.fetch(column) == value} })
            self
          end

          alias_method :and, :where
          alias_method :or,  :where

          def order(column)
            conditions.push(Proc.new{ sort_by{|r| r.fetch(column)} })
            self
          end

          def limit(number)
            modifiers.push(Proc.new{ replace(flatten.first(number)) })
            self
          end

          def offset(number)
            modifiers.unshift(Proc.new{ replace(flatten.last(number)) })
            self
          end

          def all
            result = conditions.map do |condition|
              @collection.all.instance_exec(&condition)
            end

            modifiers.map do |modifier|
              result.instance_exec(&modifier)
            end

            result
          end
        end
      end
    end
  end
end
