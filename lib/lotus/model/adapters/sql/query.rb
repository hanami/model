require 'forwardable'
require 'lotus/utils/kernel'

module Lotus
  module Model
    module Adapters
      module Sql
        class Query
          OPERATORS_MAPPING = {
            where:   :exclude,
            exclude: :where
          }.freeze

          include Enumerable
          extend  Forwardable

          def_delegators :all, :each, :to_s, :empty?
          attr_reader :conditions

          def initialize(collection, &blk)
            @collection = collection
            @conditions = []

            instance_eval(&blk) if block_given?
          end

          def all
            Lotus::Utils::Kernel.Array(run)
          end

          def where(condition)
            conditions.push([:where, condition])
            self
          end

          alias_method :and, :where

          def exclude(condition)
            conditions.push([:exclude, condition])
            self
          end

          alias_method :not, :exclude

          def select(*columns)
            conditions.push([:select, *columns])
            self
          end

          def limit(number)
            conditions.push([:limit, number])
            self
          end

          def offset(number)
            conditions.push([:offset, number])
            self
          end

          def order(column)
            conditions.push([:order, column])
            self
          end

          alias_method :asc, :order

          def desc(column)
            conditions.push([:order, Sequel.desc(column)])
            self
          end

          def or(condition)
            conditions.push([:or, condition])
            self
          end

          def sum(column)
            run.sum(column)
          end

          def average(column)
            run.avg(column)
          end

          alias_method :avg, :average

          def max(column)
            run.max(column)
          end

          def min(column)
            run.min(column)
          end

          def interval(column)
            run.interval(column)
          end

          def range(column)
            run.range(column)
          end

          def exist?
            !count.zero?
          end

          def count
            run.count
          end

          def negate!
            conditions.map! do |(operator, condition)|
              [OPERATORS_MAPPING.fetch(operator) { operator }, condition]
            end
          end

          def run
            current_scope = @collection

            conditions.each do |(method,*args)|
              current_scope = current_scope.public_send(method, *args)
            end

            current_scope
          end

          alias_method :scoped, :run
        end
      end
    end
  end
end
