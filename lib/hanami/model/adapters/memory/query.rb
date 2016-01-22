require 'forwardable'
require 'ostruct'
require 'hanami/utils/kernel'

module Hanami
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
        #        .and(framework: 'hanami')
        #        .reverse_order(:users_count).all
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
          # @param dataset [Hanami::Model::Adapters::Memory::Collection]
          # @param collection [Hanami::Model::Mapping::Collection]
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
          # @example Using block
          #
          #   query.where { age > 31 }
          #
          # @example Multiple conditions
          #
          #   query.where(language: 'ruby')
          #        .where(framework: 'hanami')
          #
          # @example Multiple conditions with blocks
          #
          #   query.where { language == 'ruby' }
          #        .where { framework == 'hanami' }
          #
          # @example Mixed hash and block conditions
          #
          #   query.where(language: 'ruby')
          #        .where { framework == 'hanami' }
          def where(condition = nil, &blk)
            if blk
              _push_evaluated_block_condition(:where, blk, :find_all)
            elsif condition
              _push_to_expanded_condition(:where, condition) do |column, value|
                Proc.new {
                  find_all { |r|
                    case value
                    when Array,Set,Range
                      value.include?(r.fetch(column, nil))
                    else
                      r.fetch(column, nil) == value
                    end
                  }
                }
              end
            end

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
          #   query.where(language: 'ruby').or(framework: 'hanami')
          #
          # @example Array
          #
          #   query.where(id: 1).or(author_id: [15, 23])
          #
          # @example Range
          #
          #   query.where(country: 'italy').or(year: 1900..1982)
          #
          # @example Using block
          #
          #   query.where { age == 31 }.or { age == 32 }
          #
          # @example Mixed hash and block conditions
          #
          #   query.where(language: 'ruby')
          #        .or { framework == 'hanami' }
          def or(condition = nil, &blk)
            if blk
              _push_evaluated_block_condition(:or, blk, :find_all)
            elsif condition
              _push_to_expanded_condition(:or, condition) do |column, value|
                Proc.new { find_all { |r| r.fetch(column) == value} }
              end
            end

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
          #
          # @example Using block
          #
          #   query.exclude { age > 31 }
          #
          # @example Multiple conditions with blocks
          #
          #   query.exclude { language == 'java' }
          #        .exclude { framework == 'spring' }
          #
          # @example Mixed hash and block conditions
          #
          #   query.exclude(language: 'java')
          #        .exclude { framework == 'spring' }
          def exclude(condition = nil, &blk)
            if blk
              _push_evaluated_block_condition(:where, blk, :reject)
            elsif condition
              _push_to_expanded_condition(:where, condition) do |column, value|
                Proc.new { reject { |r| r.fetch(column) == value} }
              end
            end

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
            columns = Hanami::Utils::Kernel.Array(columns)
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
          # @see Hanami::Model::Adapters::Memory::Query#reverse_order
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
            Hanami::Utils::Kernel.Array(columns).each do |column|
              modifiers.push(Proc.new{ sort_by!{|r| r.fetch(column)} })
            end

            self
          end

          # Alias for order
          #
          # @since 0.1.0
          #
          # @see Hanami::Model::Adapters::Memory::Query#order
          #
          # @example Single column
          #
          #   query.asc(:name)
          #
          # @example Multiple columns
          #
          #   query.asc(:name, :year)
          #
          # @example Multiple invokations
          #
          #   query.asc(:name).asc(:year)
          alias_method :asc, :order

          # Specify the descending order of the records, sorted by the given
          # columns.
          #
          # @param columns [Array<Symbol>] the column names
          #
          # @return self
          #
          # @since 0.3.1
          #
          # @see Hanami::Model::Adapters::Memory::Query#order
          #
          # @example Single column
          #
          #   query.reverse_order(:name)
          #
          # @example Multiple columns
          #
          #   query.reverse_order(:name, :year)
          #
          # @example Multiple invokations
          #
          #   query.reverse_order(:name).reverse_order(:year)
          def reverse_order(*columns)
            Hanami::Utils::Kernel.Array(columns).each do |column|
              modifiers.push(Proc.new{ sort_by!{|r| r.fetch(column)}.reverse! })
            end

            self
          end

          # Alias for reverse_order
          #
          # @since 0.1.0
          #
          # @see Hanami::Model::Adapters::Memory::Query#reverse_order
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
          alias_method :desc, :reverse_order

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
          # @see Hanami::Model::Adapters::Memory::Query#max
          # @see Hanami::Model::Adapters::Memory::Query#min
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
          # @see Hanami::Model::Adapters::Memory::Query#max
          # @see Hanami::Model::Adapters::Memory::Query#min
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
          # @see Hanami::Model::Adapters::Sql::Query#negate!
          def negate!
            raise NotImplementedError
          end

          # This method is defined in order to make the interface of
          # `Memory::Query` identical to `Sql::Query`, but this feature is NOT
          # implemented
          #
          # @raise [NotImplementedError]
          #
          # @since 0.5.0
          #
          # @see Hanami::Model::Adapters::Sql::Query#group!
          def group
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

            Hanami::Utils::Kernel.Array(result)
          end

          def _all_with_present_column(column)
            all.map {|record| record.public_send(column) }.compact
          end

          # Expands and yields keys and values of a query hash condition and
          # stores the result and condition type in the conditions array.
          #
          # It yields condition's keys and values to allow the caller to create a proc
          # object to be stored and executed later performing the actual query.
          #
          # @param condition_type [Symbol] the condition type. (eg. `:where`, `:or`)
          # @param condition [Hash] the query condition to be expanded.
          #
          # @return [Array<Array>] the conditions array itself.
          #
          # @api private
          # @since 0.3.1
          def _push_to_expanded_condition(condition_type, condition)
            proc = yield Array(condition).flatten(1)
            conditions.push([condition_type, proc])
          end

          # Evaluates a block condition of a specified type and stores it in the
          # conditions array.
          #
          # @param condition_type [Symbol] the condition type. (eg. `:where`, `:or`)
          # @param condition [Proc] the query condition to be evaluated and stored.
          # @param strategy [Symbol] the iterator method to be executed.
          #   (eg. `:find_all`, `:reject`)
          #
          # @return [Array<Array>] the conditions array itself.
          #
          # @raise [Hanami::Model::InvalidQueryError] if block raises error when
          # evaluated.
          #
          # @api private
          # @since 0.3.1
          def _push_evaluated_block_condition(condition_type, condition, strategy)
            conditions.push([condition_type, Proc.new {
              send(strategy) { |r|
                begin
                  OpenStruct.new(r).instance_eval(&condition)
                rescue NoMethodError
                  # TODO improve the error message, informing which
                  # attributes are invalid
                  raise Hanami::Model::InvalidQueryError.new
                end
              }
            }])
          end
        end
      end
    end
  end
end
