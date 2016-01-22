require 'hanami/model/coercer'
require 'hanami/utils/kernel'

module Hanami
  module Model
    module Mapping
      # Default coercers
      #
      # @since 0.5.0
      # @api private
      module Coercers
        # Array coercer
        #
        # @since 0.5.0
        # @api private
        #
        # @see Hanami::Model::Coercer
        class Array < Coercer
          # Transform a value from the database into a Ruby Array, unless nil
          #
          # @param value [Object] the object to coerce
          #
          # @return [Array] the result of the coercion
          #
          # @raise [TypeError] if the value can't be coerced
          #
          # @since 0.5.0
          # @api private
          #
          # @see Hanami::Model::Coercer.load
          # @see http://ruby-doc.org/core/Kernel.html#method-i-Array
          def self.load(value)
            ::Kernel.Array(value) unless value.nil?
          end
        end

        # Boolean coercer
        #
        # @since 0.5.0
        # @api private
        #
        # @see Hanami::Model::Coercer
        class Boolean < Coercer
          # Transform a value from the database into a Boolean, unless nil
          #
          # @param value [Object] the object to coerce
          #
          # @return [Boolean] the result of the coercion
          #
          # @raise [TypeError] if the value can't be coerced
          #
          # @since 0.5.0
          # @api private
          #
          # @see Hanami::Model::Coercer.load
          # @see http://rdoc.info/gems/hanami-utils/Hanami/Utils/Kernel#Boolean-class_method
          def self.load(value)
            Utils::Kernel.Boolean(value) unless value.nil?
          end
        end

        # Date coercer
        #
        # @since 0.5.0
        # @api private
        #
        # @see Hanami::Model::Coercer
        class Date < Coercer
          # Transform a value from the database into a Date, unless nil
          #
          # @param value [Object] the object to coerce
          #
          # @return [Date] the result of the coercion
          #
          # @raise [TypeError] if the value can't be coerced
          #
          # @since 0.5.0
          # @api private
          #
          # @see Hanami::Model::Coercer.load
          # @see http://rdoc.info/gems/hanami-utils/Hanami/Utils/Kernel#Date-class_method
          def self.load(value)
            Utils::Kernel.Date(value) unless value.nil?
          end
        end

        # DateTime coercer
        #
        # @since 0.5.0
        # @api private
        #
        # @see Hanami::Model::Coercer
        class DateTime < Coercer
          # Transform a value from the database into a DateTime, unless nil
          #
          # @param value [Object] the object to coerce
          #
          # @return [DateTime] the result of the coercion
          #
          # @raise [TypeError] if the value can't be coerced
          #
          # @since 0.5.0
          # @api private
          #
          # @see Hanami::Model::Coercer.load
          # @see http://rdoc.info/gems/hanami-utils/Hanami/Utils/Kernel#DateTime-class_method
          def self.load(value)
            Utils::Kernel.DateTime(value) unless value.nil?
          end
        end

        # Float coercer
        #
        # @since 0.5.0
        # @api private
        #
        # @see Hanami::Model::Coercer
        class Float < Coercer
          # Transform a value from the database into a Float, unless nil
          #
          # @param value [Object] the object to coerce
          #
          # @return [Float] the result of the coercion
          #
          # @raise [TypeError] if the value can't be coerced
          #
          # @since 0.5.0
          # @api private
          #
          # @see Hanami::Model::Coercer.load
          # @see http://rdoc.info/gems/hanami-utils/Hanami/Utils/Kernel#Float-class_method
          def self.load(value)
            Utils::Kernel.Float(value) unless value.nil?
          end
        end

        # Hash coercer
        #
        # @since 0.5.0
        # @api private
        #
        # @see Hanami::Model::Coercer
        class Hash < Coercer
          # Transform a value from the database into a Hash, unless nil
          #
          # @param value [Object] the object to coerce
          #
          # @return [Hash] the result of the coercion
          #
          # @raise [TypeError] if the value can't be coerced
          #
          # @since 0.5.0
          # @api private
          #
          # @see Hanami::Model::Coercer.load
          # @see http://rdoc.info/gems/hanami-utils/Hanami/Utils/Kernel#Hash-class_method
          def self.load(value)
            Utils::Kernel.Hash(value) unless value.nil?
          end
        end

        # Integer coercer
        #
        # @since 0.5.0
        # @api private
        #
        # @see Hanami::Model::Coercer
        class Integer < Coercer
          # Transform a value from the database into a Integer, unless nil
          #
          # @param value [Object] the object to coerce
          #
          # @return [Integer] the result of the coercion
          #
          # @raise [TypeError] if the value can't be coerced
          #
          # @since 0.5.0
          # @api private
          #
          # @see Hanami::Model::Coercer.load
          # @see http://rdoc.info/gems/hanami-utils/Hanami/Utils/Kernel#Integer-class_method
          def self.load(value)
            Utils::Kernel.Integer(value) unless value.nil?
          end
        end

        # BigDecimal coercer
        #
        # @since 0.5.0
        # @api private
        #
        # @see Hanami::Model::Coercer
        class BigDecimal < Coercer
          # Transform a value from the database into a BigDecimal, unless nil
          #
          # @param value [Object] the object to coerce
          #
          # @return [BigDecimal] the result of the coercion
          #
          # @raise [TypeError] if the value can't be coerced
          #
          # @since 0.5.0
          # @api private
          #
          # @see Hanami::Model::Coercer.load
          # @see http://rdoc.info/gems/hanami-utils/Hanami/Utils/Kernel#BigDecimal-class_method
          def self.load(value)
            Utils::Kernel.BigDecimal(value) unless value.nil?
          end
        end

        # Set coercer
        #
        # @since 0.5.0
        # @api private
        #
        # @see Hanami::Model::Coercer
        class Set < Coercer
          # Transform a value from the database into a Set, unless nil
          #
          # @param value [Object] the object to coerce
          #
          # @return [Set] the result of the coercion
          #
          # @raise [TypeError] if the value can't be coerced
          #
          # @since 0.5.0
          # @api private
          #
          # @see Hanami::Model::Coercer.load
          # @see http://rdoc.info/gems/hanami-utils/Hanami/Utils/Kernel#Set-class_method
          def self.load(value)
            Utils::Kernel.Set(value) unless value.nil?
          end
        end

        # String coercer
        #
        # @since 0.5.0
        # @api private
        #
        # @see Hanami::Model::Coercer
        class String < Coercer
          # Transform a value from the database into a String, unless nil
          #
          # @param value [Object] the object to coerce
          #
          # @return [String] the result of the coercion
          #
          # @raise [TypeError] if the value can't be coerced
          #
          # @since 0.5.0
          # @api private
          #
          # @see Hanami::Model::Coercer.load
          # @see http://rdoc.info/gems/hanami-utils/Hanami/Utils/Kernel#String-class_method
          def self.load(value)
            Utils::Kernel.String(value) unless value.nil?
          end
        end

        # Symbol coercer
        #
        # @since 0.5.0
        # @api private
        #
        # @see Hanami::Model::Coercer
        class Symbol < Coercer
          # Transform a value from the database into a Symbol, unless nil
          #
          # @param value [Object] the object to coerce
          #
          # @return [Symbol] the result of the coercion
          #
          # @raise [TypeError] if the value can't be coerced
          #
          # @since 0.5.0
          # @api private
          #
          # @see Hanami::Model::Coercer.load
          # @see http://rdoc.info/gems/hanami-utils/Hanami/Utils/Kernel#Symbol-class_method
          def self.load(value)
            Utils::Kernel.Symbol(value) unless value.nil?
          end
        end

        # Time coercer
        #
        # @since 0.5.0
        # @api private
        #
        # @see Hanami::Model::Coercer
        class Time < Coercer
          # Transform a value from the database into a Time, unless nil
          #
          # @param value [Object] the object to coerce
          #
          # @return [Time] the result of the coercion
          #
          # @raise [TypeError] if the value can't be coerced
          #
          # @since 0.5.0
          # @api private
          #
          # @see Hanami::Model::Coercer.load
          # @see http://rdoc.info/gems/hanami-utils/Hanami/Utils/Kernel#Time-class_method
          def self.load(value)
            Utils::Kernel.Time(value) unless value.nil?
          end
        end
      end
    end
  end
end
