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

          # Raise an error
          #
          # @since 1.0.3
          # @api private
          #
          # @see https://github.com/hanami/model/pull/453
          #
          # TODO: remove this class in hanami-model 2.0
          class RaiseError
            # @since 1.0.3
            # @api private
            def initialize(class_name)
              @class_name = class_name
            end

            # @since 1.0.3
            # @api private
            def try(input)
              raise ArgumentError.new("invalid value for #{@class_name}(): #{input.inspect}")
            end

            # @since 1.0.3
            # @api private
            def constrained?
              false
            end
          end

          # Raise an error
          #
          # @since 1.0.3
          # @api private
          #
          # @see https://github.com/hanami/model/pull/453
          #
          # TODO: remove this class in hanami-model 2.0
          class RaiseTypeError < RaiseError
            def try(input)
              raise TypeError.new("#{input.inspect} violates constraints (type?(FalseClass, #{input.inspect}) failed)")
            end
          end

          String   = Types::Optional::Coercible::String | RaiseError.new("String")

          Int      = Types::Strict::Nil | Types::Int.constructor(Coercions.method(:int)) | RaiseError.new("Integer")
          Float    = Types::Strict::Nil | Types::Float.constructor(Coercions.method(:float)) | RaiseError.new("Float")
          Decimal  = Types::Strict::Nil | Types::Decimal.constructor(Coercions.method(:decimal)) | RaiseError.new("BigDecimal")

          Bool     = Types::Strict::Nil | Types::Strict::Bool | RaiseTypeError.new("Bool")

          Date     = Types::Strict::Nil | Types::Date.constructor(Coercions.method(:date)) | RaiseError.new("Date")
          DateTime = Types::Strict::Nil | Types::DateTime.constructor(Coercions.method(:datetime)) | RaiseError.new("DateTime")
          Time     = Types::Strict::Nil | Types::Time.constructor(Coercions.method(:time)) | RaiseError.new("Time")

          Array    = Types::Strict::Nil | Types::Array.constructor(Coercions.method(:array)) | RaiseError.new("Array")
          Hash     = Types::Strict::Nil | Types::Hash.constructor(Coercions.method(:hash)) | RaiseError.new("Hash")

          PG_JSON  = Types::Strict::Nil | Types::Any.constructor(Coercions.method(:pg_json))

          # @since 0.7.0
          # @api private
          MAPPING = {
            Types::String.pristine            => Schema::String,
            Types::Int.pristine               => Schema::Int,
            Types::Float.pristine             => Schema::Float,
            Types::Decimal.pristine           => Schema::Decimal,
            Types::Bool.pristine              => Schema::Bool,
            Types::Date.pristine              => Schema::Date,
            Types::DateTime.pristine          => Schema::DateTime,
            Types::Time.pristine              => Schema::Time,
            Types::Array.pristine             => Schema::Array,
            Types::Hash.pristine              => Schema::Hash,
            Types::String.optional.pristine   => Schema::String,
            Types::Int.optional.pristine      => Schema::Int,
            Types::Float.optional.pristine    => Schema::Float,
            Types::Decimal.optional.pristine  => Schema::Decimal,
            Types::Bool.optional.pristine     => Schema::Bool,
            Types::Date.optional.pristine     => Schema::Date,
            Types::DateTime.optional.pristine => Schema::DateTime,
            Types::Time.optional.pristine     => Schema::Time,
            Types::Array.optional.pristine    => Schema::Array,
            Types::Hash.optional.pristine     => Schema::Hash
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

          # @since 1.0.2
          # @api private
          def self.pg_json?(pristine)
            (defined?(ROM::SQL::Types::PG::JSONB) && pristine == ROM::SQL::Types::PG::JSONB) ||
              (defined?(ROM::SQL::Types::PG::JSON) && pristine == ROM::SQL::Types::PG::JSON)
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
