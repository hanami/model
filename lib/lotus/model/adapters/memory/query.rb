require 'forwardable'
require 'lotus/utils/kernel'

module Lotus
  module Model
    module Adapters
      module Memory
        class Query
          include Enumerable
          extend  Forwardable

          def_delegators :all, :each, :to_s, :empty?
          attr_reader :conditions, :modifiers

          def initialize(dataset, collection, &blk)
            @dataset    = dataset
            @collection = collection
            @conditions = []
            @modifiers  = []
            instance_eval(&blk) if block_given?
          end

          def where(condition)
            column, value = *Array(condition).flatten
            conditions.push(Proc.new{ find_all{|r| r.fetch(column) == value} })
            self
          end

          alias_method :and, :where
          alias_method :or,  :where

          def exclude(condition)
            column, value = *Array(condition).flatten
            conditions.push(Proc.new{ reject! {|r| r.fetch(column) == value} })
            self
          end

          alias_method :not, :exclude

          def select(*columns)
            columns = Lotus::Utils::Kernel.Array(columns).uniq
            modifiers.push(Proc.new{ flatten!; each {|r| r.delete_if {|k,_| !columns.include?(k)} } })
          end

          def order(column)
            conditions.push(Proc.new{ sort_by{|r| r.fetch(column)} })
            self
          end

          alias_method :asc, :order

          def desc(column)
            conditions.push(Proc.new{ sort_by{|r| r.fetch(column)}.reverse })
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
            @collection.deserialize(run)
          end

          def exist?
            !count.zero?
          end

          def count
            run.count
          end

          def sum(column)
            result = all

            if result.any?
              result.inject(0.0) do |acc, record|
                if value = record.public_send(column)
                  acc += value
                end

                acc
              end
            end
          end

          def average(column)
            if s = sum(column)
              s / _all_with_present_column(column).count.to_f
            end
          end

          alias_method :avg, :average

          def max(column)
            _all_with_present_column(column).max
          end

          def min(column)
            _all_with_present_column(column).min
          end

          def interval(column)
            max(column) - min(column)
          rescue NoMethodError
          end

          def range(column)
            min(column)..max(column)
          end

          def negate!
            raise NotImplementedError
          end

          private
          def run
            result = @dataset.all.dup

            result = conditions.map do |condition|
              result.instance_exec(&condition)
            end if conditions.any?

            modifiers.map do |modifier|
              result.instance_exec(&modifier)
            end

            Lotus::Utils::Kernel.Array(result)
          end

          def _all_with_present_column(column)
            all.map {|record| record.public_send(column) }.compact
          end
        end
      end
    end
  end
end
