module Lotus
  module Model
    module Adapters
      module Memory
        class Query
          attr_reader :conditions, :modifiers

          def initialize(collection, mapper, &blk)
            @collection = collection
            @mapper     = mapper
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
            @mapper.deserialize(@collection.name, run)
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
              # TODO DRY
              # s / self.not(column => nil).count.to_f
              s / all.map {|record| record.public_send(column) }.compact.size.to_f
            end
          end

          alias_method :avg, :average

          def max(column)
            # TODO DRY
            all.map {|record| record.public_send(column) }.compact.max
          end

          def min(column)
            # TODO DRY
            all.map {|record| record.public_send(column) }.compact.min
          end

          def interval(column)
            max(column) - min(column)
          rescue NoMethodError
          end

          def range(column)
            min(column)..max(column)
          end

          private
          def run
            result = @collection.all.dup

            result = conditions.map do |condition|
              result.instance_exec(&condition)
            end if conditions.any?

            modifiers.map do |modifier|
              result.instance_exec(&modifier)
            end

            Lotus::Utils::Kernel.Array(result)
          end
        end
      end
    end
  end
end
