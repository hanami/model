# frozen_string_literal: true

require "hanami/model/types"
require "rom/types"

module Hanami
  module Model
    module Sql
      # Types definitions for SQL databases
      #
      # @since 0.7.0
      module Types
        # FIXME: check if including Dry.Types here is still needed
        include Dry.Types(default: :nominal)
        include Hanami::Model::Types

        # Types for schema definitions
        #
        # @since 0.7.0
        module Schema
          require "hanami/model/sql/types/schema/coercions"

          String   = Types::Optional::Coercible::String

          Integer  = Types::Strict::Nil | Types::Strict::Integer.constructor(Coercions.method(:int))
          Float    = Types::Strict::Nil | Types::Strict::Float.constructor(Coercions.method(:float))
          Decimal  = Types::Strict::Nil | Types::Strict::Decimal.constructor(Coercions.method(:decimal))

          Bool     = Types::Strict::Nil | Types::Strict::Bool

          Date     = Types::Strict::Nil | Types::Strict::Date.constructor(Coercions.method(:date))
          DateTime = Types::Strict::Nil | Types::Strict::DateTime.constructor(Coercions.method(:datetime))
          Time     = Types::Strict::Nil | Types::Strict::Time.constructor(Coercions.method(:time))

          Array    = Types::Strict::Nil | Types::Strict::Array.constructor(Coercions.method(:array))
          Hash     = Types::Strict::Nil | Types::Strict::Hash.constructor(Coercions.method(:hash))

          PG_JSON  = Types::Strict::Nil | Types::Any.constructor(Coercions.method(:pg_json))

          # @since 0.7.0
          # @api private
          MAPPING = {
            Types::String.pristine => Schema::String,
            Types::Integer.pristine => Schema::Integer,
            Types::Float.pristine => Schema::Float,
            Types::Decimal.pristine => Schema::Decimal,
            Types::Bool.pristine => Schema::Bool,
            Types::Date.pristine => Schema::Date,
            Types::DateTime.pristine => Schema::DateTime,
            Types::Time.pristine => Schema::Time,
            Types::Array.pristine => Schema::Array,
            Types::Hash.pristine => Schema::Hash,
            Types::String.optional.pristine => Schema::String,
            Types::Integer.optional.pristine => Schema::Integer,
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
            pristine == pg_json_pristines["JSONB"] || # rubocop:disable Style/MultipleComparison
              pristine == pg_json_pristines["JSON"]
          end

          private_class_method :pg_json?
        end
      end
    end
  end
end
