require 'forwardable'
require 'lotus/utils/kernel'

module Lotus
  module Model
    module Adapters
      module Sql
        # Query the database with a powerful API.
        #
        # All the methods are chainable, it allows advanced composition of
        # SQL conditions.
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
          # Define negations for operators.
          #
          # @see Lotus::Model::Adapters::Sql::Query#negate!
          #
          # @api private
          # @since 0.1.0
          OPERATORS_MAPPING = {
            where:   :exclude,
            exclude: :where
          }.freeze

          include Enumerable
          extend  Forwardable

          def_delegators :all, :each, :to_s, :empty?

          # @attr_reader conditions [Array] an accumulator for the called
          #   methods
          #
          # @since 0.1.0
          # @api private
          attr_reader :conditions

          # Initialize a query
          #
          # @param collection [Lotus::Model::Adapters::Sql::Collection] the
          #   collection to query
          #
          # @param blk [Proc] an optional block that gets yielded in the
          #   context of the current query
          #
          # @return [Lotus::Model::Adapters::Sql::Query]
          def initialize(collection, context = nil, &blk)
            @collection, @context = collection, context
            @conditions = []

            instance_eval(&blk) if block_given?
          end

          # Resolves the query by fetching records from the database and
          # translating them into entities.
          #
          # @return [Array] a collection of entities
          #
          # @since 0.1.0
          def all
            run.to_a
          end

          # Adds a SQL `WHERE` condition.
          #
          # It accepts a `Hash` with only one pair.
          # The key must be the name of the column expressed as a `Symbol`.
          # The value is the one used by the SQL query
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
          #   # => SELECT * FROM `projects` WHERE (`language` = 'ruby')
          #
          # @example Array
          #
          #   query.where(id: [1, 3])
          #
          #   # => SELECT * FROM `articles` WHERE (`id` IN (1, 3))
          #
          # @example Range
          #
          #   query.where(year: 1900..1982)
          #
          #   # => SELECT * FROM `people` WHERE ((`year` >= 1900) AND (`year` <= 1982))
          #
          # @example Multiple conditions
          #
          #   query.where(language: 'ruby')
          #        .where(framework: 'lotus')
          #
          #   # => SELECT * FROM `projects` WHERE (`language` = 'ruby') AND (`framework` = 'lotus')
          #
          # @example Expressions
          #
          #   query.where{ age > 10 }
          #
          #   # => SELECT * FROM `users` WHERE (`age` > 31)
          def where(condition=nil, &blk)
            condition = (condition or blk or raise ArgumentError.new('You need to specify a condition.'))
            conditions.push([:where, condition])
            self
          end

          alias_method :and, :where

          # Adds a SQL `OR` condition.
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
          #   # => SELECT * FROM `projects` WHERE ((`language` = 'ruby') OR (`framework` = 'lotus'))
          #
          # @example Array
          #
          #   query.where(id: 1).or(author_id: [15, 23])
          #
          #   # => SELECT * FROM `articles` WHERE ((`id` = 1) OR (`author_id` IN (15, 23)))
          #
          # @example Range
          #
          #   query.where(country: 'italy').or(year: 1900..1982)
          #
          #   # => SELECT * FROM `people` WHERE ((`country` = 'italy') OR ((`year` >= 1900) AND (`year` <= 1982)))
          #
          # @example Expressions
          #
          #   query.where(name: 'John').or{ age > 31 }
          #
          #   # => SELECT * FROM `users` WHERE ((`name` = 'John') OR (`age` < 32))
          def or(condition=nil, &blk)
            condition = (condition or blk or raise ArgumentError.new('You need to specify a condition.'))
            conditions.push([:or, condition])
            self
          end

          # Logical negation of a WHERE condition.
          #
          # It accepts a `Hash` with only one pair.
          # The key must be the name of the column expressed as a `Symbol`.
          # The value is the one used by the SQL query
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
          #   # => SELECT * FROM `projects` WHERE (`language` != 'java')
          #
          # @example Array
          #
          #   query.exclude(id: [4, 9])
          #
          #   # => SELECT * FROM `articles` WHERE (`id` NOT IN (1, 3))
          #
          # @example Range
          #
          #   query.exclude(year: 1900..1982)
          #
          #   # => SELECT * FROM `people` WHERE ((`year` < 1900) AND (`year` > 1982))
          #
          # @example Multiple conditions
          #
          #   query.exclude(language: 'java')
          #        .exclude(company: 'enterprise')
          #
          #   # => SELECT * FROM `projects` WHERE (`language` != 'java') AND (`company` != 'enterprise')
          # @example Expressions
          #
          #   query.exclude{ age > 31 }
          #
          #   # => SELECT * FROM `users` WHERE (`age` <= 31)
          def exclude(condition=nil, &blk)
            condition = (condition or blk or raise ArgumentError.new('You need to specify a condition.'))
            conditions.push([:exclude, condition])
            self
          end

          alias_method :not, :exclude

          # Select only the specified columns.
          #
          # By default a query selects all the columns of a table (`SELECT *`).
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
          #   # => SELECT `name` FROM `people`
          #
          # @example Multiple columns
          #
          #   query.select(:name, :year)
          #
          #   # => SELECT `name`, `year` FROM `people`
          def select(*columns)
            conditions.push([:select, *columns])
            self
          end

          # Limit the number of records to return.
          #
          # This operation is performed at the database level with `LIMIT`.
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
          #
          #   # => SELECT * FROM `people` LIMIT 1
          def limit(number)
            conditions.push([:limit, number])
            self
          end

          # Specify an `OFFSET` clause.
          #
          # Due to SQL syntax restriction, offset MUST be used with `#limit`.
          #
          # @param number [Fixnum]
          #
          # @return self
          #
          # @since 0.1.0
          #
          # @see Lotus::Model::Adapters::Sql::Query#limit
          #
          # @example
          #
          #   query.limit(1).offset(10)
          #
          #   # => SELECT * FROM `people` LIMIT 1 OFFSET 10
          def offset(number)
            conditions.push([:offset, number])
            self
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
          #   # => SELECT * FROM `people` ORDER BY (`name`)
          #
          # @example Multiple columns
          #
          #   query.order(:name, :year)
          #
          #   # => SELECT * FROM `people` ORDER BY `name`, `year`
          #
          # @example Multiple invokations
          #
          #   query.order(:name).order(:year)
          #
          #   # => SELECT * FROM `people` ORDER BY `name`, `year`
          def order(*columns)
            conditions.push([_order_operator, *columns])
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
          #   # => SELECT * FROM `people` ORDER BY (`name`) DESC
          #
          # @example Multiple columns
          #
          #   query.desc(:name, :year)
          #
          #   # => SELECT * FROM `people` ORDER BY `name`, `year` DESC
          #
          # @example Multiple invokations
          #
          #   query.desc(:name).desc(:year)
          #
          #   # => SELECT * FROM `people` ORDER BY `name`, `year` DESC
          def desc(*columns)
            Array(columns).each do |column|
              conditions.push([_order_operator, Sequel.desc(column)])
            end

            self
          end

          def sql
            scoped.sql
          end

          def join(collection, options = {})
            # FIXME This is a poor man's singularization, implement in Lotus::Utils
            collection_name = collection.to_s
            collection_name = case collection_name
            when ->(s) { s.match(/ies\z/) }
              collection_name.sub(/ies\z/, 'y')
            else
              collection_name.sub(/s\z/, '')
            end

            foreign_key = options.fetch(:foreign_key) { "#{ @collection.table_name }__#{ collection_name }_id".to_sym }
            # FIXME this should correspond to the table's primary key
            key         = options.fetch(:key) { "#{ collection }__id".to_sym }

            conditions.push([:select_all])
            conditions.push([:join_table, :inner, collection, key => foreign_key])

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
          #
          #    # => SELECT SUM(`comments_count`) FROM articles
          def sum(column)
            run.sum(column)
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
          #
          #    # => SELECT AVG(`comments_count`) FROM articles
          def average(column)
            run.avg(column)
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
          # @example With numeric type
          #
          #    query.max(:comments_count)
          #
          #    # => SELECT MAX(`comments_count`) FROM articles
          #
          # @example With string type
          #
          #    query.max(:title)
          #
          #    # => SELECT MAX(`title`) FROM articles
          def max(column)
            run.max(column)
          end

          # Returns the minimum value for the given column.
          #
          # @param column [Symbol] the column name
          #
          # @return result
          #
          # @since 0.1.0
          #
          # @example With numeric type
          #
          #    query.min(:comments_count)
          #
          #    # => SELECT MIN(`comments_count`) FROM articles
          #
          # @example With string type
          #
          #    query.min(:title)
          #
          #    # => SELECT MIN(`title`) FROM articles
          def min(column)
            run.min(column)
          end

          # Returns the difference between the MAX and MIN for the given column.
          #
          # @param column [Symbol] the column name
          #
          # @return [Numeric]
          #
          # @since 0.1.0
          #
          # @see Lotus::Model::Adapters::Sql::Query#max
          # @see Lotus::Model::Adapters::Sql::Query#min
          #
          # @example
          #
          #    query.interval(:comments_count)
          #
          #    # => SELECT (MAX(`comments_count`) - MIN(`comments_count`)) FROM articles
          def interval(column)
            run.interval(column)
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
          # @see Lotus::Model::Adapters::Sql::Query#max
          # @see Lotus::Model::Adapters::Sql::Query#min
          #
          # @example
          #
          #    query.range(:comments_count)
          #
          #    # => SELECT MAX(`comments_count`) AS v1, MIN(`comments_count`) AS v2 FROM articles
          def range(column)
            run.range(column)
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

          # Negates the current where/exclude conditions with the logical
          # opposite operator.
          #
          # All the other conditions will be ignored.
          #
          # @since 0.1.0
          #
          # @see Lotus::Model::Adapters::Sql::Query#where
          # @see Lotus::Model::Adapters::Sql::Query#exclude
          # @see Lotus::Repository#exclude
          #
          # @example
          #
          #   query.where(language: 'java').negate!.all
          #
          #   # => SELECT * FROM `projects` WHERE (`language` != 'java')
          def negate!
            conditions.map! do |(operator, condition)|
              [OPERATORS_MAPPING.fetch(operator) { operator }, condition]
            end
          end

          # Apply all the conditions and returns a filtered collection.
          #
          # This operation is idempotent, and the returned result didn't
          # fetched the records yet.
          #
          # @return [Lotus::Model::Adapters::Sql::Collection]
          #
          # @since 0.1.0
          def scoped
            scope = @collection

            conditions.each do |(method,*args)|
              scope = scope.public_send(method, *args)
            end

            scope
          end

          alias_method :run, :scoped

          protected
          # Handles missing methods for query combinations
          #
          # @api private
          # @since 0.1.0
          #
          # @see Lotus::Model::Adapters:Sql::Query#apply
          def method_missing(m, *args, &blk)
            if @context.respond_to?(m)
              apply @context.public_send(m, *args, &blk)
            else
              super
            end
          end

          private

          # Returns a new query that is the result of the merge of the current
          # conditions with the ones of the given query.
          #
          # This is used to combine queries together in a Repository.
          #
          # @param query [Lotus::Model::Adapters::Sql::Query] the query to apply
          #
          # @return [Lotus::Model::Adapters::Sql::Query] a new query with the
          #   merged conditions
          #
          # @api private
          # @since 0.1.0
          #
          # @example
          #   require 'lotus/model'
          #
          #   class ArticleRepository
          #     include Lotus::Repository
          #
          #     def self.by_author(author)
          #       query do
          #         where(author_id: author.id)
          #       end
          #     end
          #
          #     def self.rank
          #       query.desc(:comments_count)
          #     end
          #
          #     def self.rank_by_author(author)
          #       rank.by_author(author)
          #     end
          #   end
          #
          #   # The code above combines two queries: `rank` and `by_author`.
          #   #
          #   # The first class method `rank` returns a `Sql::Query` instance
          #   # which doesn't respond to `by_author`. How to solve this problem?
          #   #
          #   # 1. When we use `query` to fabricate a `Sql::Query` we pass the
          #   # current context (the repository itself) to the query initializer.
          #   #
          #   # 2. When that query receives the `by_author` message, it's captured
          #   # by `method_missing` and dispatched to the repository.
          #   #
          #   # 3. The class method `by_author` returns a query too.
          #   #
          #   # 4. We just return a new query that is the result of the current
          #   # query's conditions (`rank`) and of the conditions from `by_author`.
          #   #
          #   # You're welcome ;)
          def apply(query)
            dup.tap do |result|
              result.conditions.push(*query.conditions)
            end
          end

          def _order_operator
            if conditions.any? {|c, _| c == :order }
              :order_more
            else
              :order
            end
          end
        end
      end
    end
  end
end
