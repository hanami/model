require 'rom/types'

module Hanami
  module Model
    # Types definitions
    #
    # @since x.x.x
    module Types
      include ROM::Types

      # @since x.x.x
      # @api private
      def self.included(mod)
        mod.extend(ClassMethods)
      end

      # Class level interface
      #
      # @since x.x.x
      module ClassMethods
        # Define an array of given type
        #
        # @since x.x.x
        def Collection(type) # rubocop:disable Style/MethodName
          type = Schema::CoercibleType.new(type) unless type.is_a?(Dry::Types::Definition)
          Types::Array.member(type)
        end
      end

      # Types for schema definitions
      #
      # @since x.x.x
      module Schema
        # Coercer for objects within custom schema definition
        #
        # @since x.x.x
        # @api private
        class CoercibleType < Dry::Types::Definition
          # Coerce given value into the wrapped object type
          #
          # @param value [Object] the value
          #
          # @return [Object] the coerced value of `object` type
          #
          # @raise [TypeError] if value can't be coerced
          #
          # @since x.x.x
          # @api private
          def call(value)
            if valid?(value)
              coerce(value)
            else
              raise TypeError.new("#{value.inspect} must be coercible into #{object}")
            end
          end

          # Check if value can be coerced
          #
          # It is true if value is an instance of `object` type or if value
          # respond to `#to_hash`.
          #
          # @param value [Object] the value
          #
          # @return [TrueClass,FalseClass] the result of the check
          #
          # @since x.x.x
          # @api private
          def valid?(value)
            value.is_a?(object) ||
              value.respond_to?(:to_hash)
          end

          # Coerce given value into an instance of `object` type
          #
          # @param value [Object] the value
          #
          # @return [Object] the coerced value of `object` type
          def coerce(value)
            case value
            when object
              value
            else
              object.new(value.to_hash)
            end
          end

          # @since x.x.x
          # @api private
          def object
            result = primitive
            return result unless result.respond_to?(:primitive)

            result.primitive
          end
        end
      end
    end
  end
end
