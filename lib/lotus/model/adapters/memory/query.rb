require 'forwardable'
require 'lotus/utils/kernel'

module Lotus
  module Model
    module Adapters
      module Memory
        # Query the in-memory database with a powerful API.
        #
        # All the methods are chainable, it allows advanced composition of
        # conditions.
        #
        # This works as a lazy filtering mechanism: the records are fetched from
        # the database only when needed.
        #
        # @example
        #
        #   query.where(language: 'ruby')
        #        .and(framework: 'lotus')
        #        .desc(:users_count).all
        #
        #   # the records are fetched only when we invoke #all
        #
        # It implements Ruby's `Enumerable` and borrows some methods from `Array`.
        # Expect a query to act like them.
        #
        # @since 0.1.0
        class Query
          include Enumerable
          extend  Forwardable

          def_delegators :all, :each, :to_s, :empty?

          # @attr_reader conditions [Array] an accumulator for the conditions
          #
          # @since 0.1.0
          # @api private
          attr_reader :conditions

          # @attr_reader modifiers [Array] an accumulator for the modifiers
          #
          # @since 0.1.0
          # @api private
          attr_reader :modifiers

          # Initialize a query
          #
          # @param dataset [Lotus::Model::Adapters::Memory::Collection]
          # @param collection [Lotus::Model::Mapping::Collection]
          # @param blk [Proc] an optional block that gets yielded in the
          #   context of the current query
          #
          # @since 0.1.0
          # @api private
          def initialize(dataset, collection, &blk)
            @dataset    = dataset
            @collection = collection
            @conditions = []
            @modifiers  = []
            instance_eval(&blk) if block_given?
          end

          # Resolves the query by fetching records from the database and
          # translating them into entities.
          #
          # @return [Array] a collection of entities
          #
          # @since 0.1.0
          def all
            @collection.deserialize(run)
          end

          # Adds a condition that behaves like SQL `WHERE`.
          #
          # It accepts a `Hash` with only one pair.
          # The key must be the name of the column expressed as a `Symbol`.
          # The value is the one used by the internal filtering logic.
          #
          # @param condition [Hash]
          #
          # @return self
          #
          # @since 0.1.0
          #
          # @example Fixed value
          #
          #   query.where(language: 'ruby')
          #
          # @example Array
          #
          #   query.where(id: [1, 3])
          #
          # @example Range
          #
          #   query.where(year: 1900..1982)
          #
          # @example Multiple conditions
          #
          #   query.where(language: 'ruby')
          #        .where(framework: 'lotus')
          def where(condition)
            column, value = _expand_condition(condition)
            conditions.push([:where, Proc.new{ find_all{|r| r.fetch(column, nil) == value} }])
            self
          end

          alias_method :and, :where

          # Adds a condition that behaves like SQL `OR`.
          #
          # It accepts a `Hash` with only one pair.
          # The key must be the name of the column expressed as a `Symbol`.
          # The value is the one used by the SQL query
          #
          # This condition will be ignored if not used with WHERE.
          #
          # @param condition [Hash]
          #
          # @return self
          #
          # @since 0.1.0
          #
          # @example Fixed value
          #
          #   query.where(language: 'ruby').or(framework: 'lotus')
          #
          # @example Array
          #
          #   query.where(id: 1).or(author_id: [15, 23])
          #
          # @example Range
          #
          #   query.where(country: 'italy').or(year: 1900..1982)
          def or(condition=nil, &blk)
            column, value = _expand_condition(condition)
            conditions.push([:or, Proc.new{ find_all{|r| r.fetch(column) == value} }])
            self
          end

          # Logical negation of a #where condition.
          #
          # It accepts a `Hash` with only one pair.
          # The key must be the name of the column expressed as a `Symbol`.
          # The value is the one used by the internal filtering logic.
          #
          # @param condition [Hash]
          #
          # @since 0.1.0
          #
          # @return self
          #
          # @example Fixed value
          #
          #   query.exclude(language: 'java')
          #
          # @example Array
          #
          #   query.exclude(id: [4, 9])
          #
          # @example Range
          #
          #   query.exclude(year: 1900..1982)
          #
          # @example Multiple conditions
          #
          #   query.exclude(language: 'java')
          #        .exclude(company: 'enterprise')
          def exclude(condition)
            column, value = _expand_condition(condition)
            conditions.push([:where, Proc.new{ reject {|r| r.fetch(column) == value} }])
            self
          end

          alias_method :not, :exclude

          # Select only the specified columns.
          #
          # By default a query selects all the mapped columns.
          #
          # @param columns [Array<Symbol>]
          #
          # @return self
          #
          # @since 0.1.0
          #
          # @example Single column
          #
          #   query.select(:name)
          #
          # @example Multiple columns
          #
          #   query.select(:name, :year)
          def select(*columns)
            columns = Lotus::Utils::Kernel.Array(columns)
            modifiers.push(Proc.new{ flatten!; each {|r| r.delete_if {|k,_| !columns.include?(k)} } })
          end

          # Specify the ascending order of the records, sorted by the given
          # columns.
          #
          # @param columns [Array<Symbol>] the column names
          #
          # @return self
          #
          # @since 0.1.0
          #
          # @see Lotus::Model::Adapters::Sql::Query#desc
          #
          # @example Single column
          #
          #   query.order(:name)
          #
          # @example Multiple columns
          #
          #   query.order(:name, :year)
          #
          # @example Multiple invokations
          #
          #   query.order(:name).order(:year)
          def order(*columns)
            Lotus::Utils::Kernel.Array(columns).each do |column|
              modifiers.push(Proc.new{ sort_by!{|r| r.fetch(column)} })
            end

            self
          end

          alias_method :asc, :order

          # Specify the descending order of the records, sorted by the given
          # columns.
          #
          # @param columns [Array<Symbol>] the column names
          #
          # @return self
          #
          # @since 0.1.0
          #
          # @see Lotus::Model::Adapters::Sql::Query#order
          #
          # @example Single column
          #
          #   query.desc(:name)
          #
          # @example Multiple columns
          #
          #   query.desc(:name, :year)
          #
          # @example Multiple invokations
          #
          #   query.desc(:name).desc(:year)
          def desc(*columns)
            Lotus::Utils::Kernel.Array(columns).each do |column|
              modifiers.push(Proc.new{ sort_by!{|r| r.fetch(column)}.reverse! })
            end

            self
          end

          # Limit the number of records to return.
          #
          # @param number [Fixnum]
          #
          # @return self
          #
          # @since 0.1.0
          #
          # @example
          #
          #   query.limit(1)
          def limit(number)
            modifiers.push(Proc.new{ replace(flatten.first(number)) })
            self
          end

          # Simulate an `OFFSET` clause, without the need of specify a limit.
          #
          # @param number [Fixnum]
          #
          # @return self
          #
          # @since 0.1.0
          #
          # @example
          #
          #   query.offset(10)
          def offset(number)
            modifiers.unshift(Proc.new{ replace(flatten.drop(number)) })
            self
          end

          # Returns the sum of the values for the given column.
          #
          # @param column [Symbol] the column name
          #
          # @return [Numeric]
          #
          # @since 0.1.0
          #
          # @example
          #
          #    query.sum(:comments_count)
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

          # Returns the average of the values for the given column.
          #
          # @param column [Symbol] the column name
          #
          # @return [Numeric]
          #
          # @since 0.1.0
          #
          # @example
          #
          #    query.average(:comments_count)
          def average(column)
            if s = sum(column)
              s / _all_with_present_column(column).count.to_f
            end
          end

          alias_method :avg, :average

          # Returns the maximum value for the given column.
          #
          # @param column [Symbol] the column name
          #
          # @return result
          #
          # @since 0.1.0
          #
          # @example
          #
          #    query.max(:comments_count)
          def max(column)
            _all_with_present_column(column).max
          end

          # Returns the minimum value for the given column.
          #
          # @param column [Symbol] the column name
          #
          # @return result
          #
          # @since 0.1.0
          #
          # @example
          #
          #    query.min(:comments_count)
          def min(column)
            _all_with_present_column(column).min
          end

          # Returns the difference between the MAX and MIN for the given column.
          #
          # @param column [Symbol] the column name
          #
          # @return [Numeric]
          #
          # @since 0.1.0
          #
          # @see Lotus::Model::Adapters::Memory::Query#max
          # @see Lotus::Model::Adapters::Memory::Query#min
          #
          # @example
          #
          #    query.interval(:comments_count)
          def interval(column)
            max(column) - min(column)
          rescue NoMethodError
          end

          # Returns a range of values between the MAX and the MIN for the given
          # column.
          #
          # @param column [Symbol] the column name
          #
          # @return [Range]
          #
          # @since 0.1.0
          #
          # @see Lotus::Model::Adapters::Memory::Query#max
          # @see Lotus::Model::Adapters::Memory::Query#min
          #
          # @example
          #
          #    query.range(:comments_count)
          def range(column)
            min(column)..max(column)
          end

          # Checks if at least one record exists for the current conditions.
          #
          # @return [TrueClass,FalseClass]
          #
          # @since 0.1.0
          #
          # @example
          #
          #    query.where(author_id: 23).exists? # => true
          def exist?
            !count.zero?
          end

          # Returns a count of the records for the current conditions.
          #
          # @return [Fixnum]
          #
          # @since 0.1.0
          #
          # @example
          #
          #    query.where(author_id: 23).count # => 5
          def count
            run.count
          end

          # This method is defined in order to make the interface of
          # `Memory::Query` identical to `Sql::Query`, but this feature is NOT
          # implemented
          #
          # @raise [NotImplementedError]
          #
          # @since 0.1.0
          #
          # @see Lotus::Model::Adapters::Sql::Query#negate!
          def negate!
            raise NotImplementedError
          end

          protected
          def method_missing(m, *args, &blk)
            if @context.respond_to?(m)
              apply @context.public_send(m, *args, &blk)
            else
              super
            end
          end

          private
          # Apply all the conditions and returns a filtered collection.
          #
          # This operation is idempotent, but the records are actually fetched
          # from the memory store.
          #
          # @return [Array]
          #
          # @api private
          # @since 0.1.0
          def run
            result = @dataset.all.dup

            if conditions.any?
              prev_result = nil
              conditions.each do |(type, condition)|
                case type
                when :where
                  prev_result = result
                  result = prev_result.instance_exec(&condition)
                when :or
                  result |= prev_result.instance_exec(&condition)
                end
              end
            end

            modifiers.map do |modifier|
              result.instance_exec(&modifier)
            end

            Lotus::Utils::Kernel.Array(result)
          end

          def _all_with_present_column(column)
            all.map {|record| record.public_send(column) }.compact
          end

          def _expand_condition(condition)
            Array(condition).flatten
          end
        end
      end
    end
  end
end
