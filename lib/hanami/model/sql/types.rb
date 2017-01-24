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
          Hash     = Types::Strict::Nil | Types::Array.constructor(Coercions.method(:hash))

          # @since 0.7.0
          # @api private
          MAPPING = {
            Types::String.with(meta: {})            => Schema::String,
            Types::Int.with(meta: {})               => Schema::Int,
            Types::Float.with(meta: {})             => Schema::Float,
            Types::Decimal.with(meta: {})           => Schema::Decimal,
            Types::Bool.with(meta: {})              => Schema::Bool,
            Types::Date.with(meta: {})              => Schema::Date,
            Types::DateTime.with(meta: {})          => Schema::DateTime,
            Types::Time.with(meta: {})              => Schema::Time,
            Types::Array.with(meta: {})             => Schema::Array,
            Types::Hash.with(meta: {})              => Schema::Hash,
            Types::String.optional.with(meta: {})   => Schema::String,
            Types::Int.optional.with(meta: {})      => Schema::Int,
            Types::Float.optional.with(meta: {})    => Schema::Float,
            Types::Decimal.optional.with(meta: {})  => Schema::Decimal,
            Types::Bool.optional.with(meta: {})     => Schema::Bool,
            Types::Date.optional.with(meta: {})     => Schema::Date,
            Types::DateTime.optional.with(meta: {}) => Schema::DateTime,
            Types::Time.optional.with(meta: {})     => Schema::Time,
            Types::Array.optional.with(meta: {})    => Schema::Array,
            Types::Hash.optional.with(meta: {})     => Schema::Hash
          }.freeze

          # Convert given type into coercible
          #
          # @since 0.7.0
          # @api private
          def self.coercible(attribute)
            return attribute if attribute.constrained?
            # TODO: figure out a better way of inferring coercions from schema types
            MAPPING.fetch(attribute.type.with(meta: {}), attribute)
          end

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
