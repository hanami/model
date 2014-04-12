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
              # s / self.not(column => nil).count.to_f
              s / run.find_all{|record| !!record[column] }.size.to_f
            end
          end

          alias_method :avg, :average

          private
          def run
            # TODO cleanup
            result = if conditions.any?
                       conditions.map do |condition|
                         @collection.all.instance_exec(&condition)
                       end
                     else
                       @collection.all
                     end

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
