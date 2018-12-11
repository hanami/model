require 'hanami/model/types'
require 'rom/types'

module Hanami
  module Model
    module Sql
      # Types definitions for SQL databases
      #
      # @since 0.7.0
      module Types
        include Dry::Types.module

        # Types for schema definitions
        #
        # @since 0.7.0
        module Schema
          require 'hanami/model/sql/types/schema/coercions'

          String   = Types::Optional::Coercible::String

          Int      = Types::Strict::Nil | Types::Int.constructor(Coercions.method(:int))
          Float    = Types::Strict::Nil | Types::Float.constructor(Coercions.method(:float))
          Decimal  = Types::Strict::Nil | Types::Float.constructor(Coercions.method(:decimal))

          Bool     = Types::Strict::Nil | Types::Strict::Bool

          Date     = Types::Strict::Nil | Types::Date.constructor(Coercions.method(:date))
          DateTime = Types::Strict::Nil | Types::DateTime.constructor(Coercions.method(:datetime))
          Time     = Types::Strict::Nil | Types::Time.constructor(Coercions.method(:time))

          Array    = Types::Strict::Nil | Types::Array.constructor(Coercions.method(:array))
          Hash     = Types::Strict::Nil | Types::Hash.constructor(Coercions.method(:hash))

          PG_JSON  = Types::Strict::Nil | Types::Any.constructor(Coercions.method(:pg_json))

          # @since 0.7.0
          # @api private
          MAPPING = {
            Types::String.pristine => Schema::String,
            Types::Int.pristine => Schema::Int,
            Types::Float.pristine => Schema::Float,
            Types::Decimal.pristine => Schema::Decimal,
            Types::Bool.pristine => Schema::Bool,
            Types::Date.pristine => Schema::Date,
            Types::DateTime.pristine => Schema::DateTime,
            Types::Time.pristine => Schema::Time,
            Types::Array.pristine => Schema::Array,
            Types::Hash.pristine => Schema::Hash,
            Types::String.optional.pristine => Schema::String,
            Types::Int.optional.pristine => Schema::Int,
            Types::Float.optional.pristine => Schema::Float,
            Types::Decimal.optional.pristine => Schema::Decimal,
            Types::Bool.optional.pristine => Schema::Bool,
            Types::Date.optional.pristine => Schema::Date,
            Types::DateTime.optional.pristine => Schema::DateTime,
            Types::Time.optional.pristine => Schema::Time,
            Types::Array.optional.pristine => Schema::Array,
            Types::Hash.optional.pristine => Schema::Hash
          }.freeze

          # Convert given type into coercible
          #
          # @since 0.7.0
          # @api private
          def self.coercible(attribute)
            return attribute if attribute.constrained?

            type      = attribute.type
            unwrapped = type.optional? ? type.right : type

            # NOTE: In the future rom-sql should be able to always return Ruby
            # types instead of Sequel types. When that will happen we can get
            # rid of this logic in the block and fall back to:
            #
            #  MAPPING.fetch(unwrapped.pristine, attribute)
            MAPPING.fetch(unwrapped.pristine) do
              if pg_json?(unwrapped.pristine)
                Schema::PG_JSON
              else
                attribute
              end
            end
          end

          # @since 1.0.4
          # @api private
          def self.pg_json_pristines
            @pg_json_pristines ||= ::Hash.new do |hash, type|
              hash[type] = (ROM::SQL::Types::PG.const_get(type).pristine if defined?(ROM::SQL::Types::PG))
            end
          end

          # @since 1.0.2
          # @api private
          def self.pg_json?(pristine)
            pristine == pg_json_pristines['JSONB'.freeze] || # rubocop:disable Style/MultipleComparison
              pristine == pg_json_pristines['JSON'.freeze]
          end

          private_class_method :pg_json?

          # Coercer for SQL associations target
          #
          # @since 0.7.0
          # @api private
          class AssociationType < Hanami::Model::Types::Schema::CoercibleType
            # Check if value can be coerced
            #
            # @param value [Object] the value
            #
            # @return [TrueClass,FalseClass] the result of the check
            #
            # @since 0.7.0
            # @api private
            def valid?(value)
              value.inspect =~ /\[#{primitive}\]/ || super
            end

            # @since 0.7.0
            # @api private
            def success(*args)
              result(Dry::Types::Result::Success, primitive.new(args.first.to_h))
            end
          end
        end
      end
    end
  end
end
