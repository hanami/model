require 'lotus/model/coercer'
require 'lotus/utils/kernel'

module Lotus
  module Model
    module Mapping
      # Default coercers
      #
      # @since x.x.x
      # @api private
      module Coercers
        # Array coercer
        #
        # @since x.x.x
        # @api private
        #
        # @see Lotus::Model::Coercer
        class Array < Coercer
          # Transform a value from the database into a Ruby Array, unless nil
          #
          # @param value [Object] the object to coerce
          #
          # @return [Array] the result of the coercion
          #
          # @raise [TypeError] if the value can't be coerced
          #
          # @since x.x.x
          # @api private
          #
          # @see Lotus::Model::Coercer.load
          # @see http://ruby-doc.org/core/Kernel.html#method-i-Array
          def self.load(value)
            ::Kernel.Array(value) unless value.nil?
          end
        end

        # Boolean coercer
        #
        # @since x.x.x
        # @api private
        #
        # @see Lotus::Model::Coercer
        class Boolean < Coercer
          # Transform a value from the database into a Boolean, unless nil
          #
          # @param value [Object] the object to coerce
          #
          # @return [Boolean] the result of the coercion
          #
          # @raise [TypeError] if the value can't be coerced
          #
          # @since x.x.x
          # @api private
          #
          # @see Lotus::Model::Coercer.load
          # @see http://rdoc.info/gems/lotus-utils/Lotus/Utils/Kernel#Boolean-class_method
          def self.load(value)
            Utils::Kernel.Boolean(value) unless value.nil?
          end
        end

        # Date coercer
        #
        # @since x.x.x
        # @api private
        #
        # @see Lotus::Model::Coercer
        class Date < Coercer
          # Transform a value from the database into a Date, unless nil
          #
          # @param value [Object] the object to coerce
          #
          # @return [Date] the result of the coercion
          #
          # @raise [TypeError] if the value can't be coerced
          #
          # @since x.x.x
          # @api private
          #
          # @see Lotus::Model::Coercer.load
          # @see http://rdoc.info/gems/lotus-utils/Lotus/Utils/Kernel#Date-class_method
          def self.load(value)
            Utils::Kernel.Date(value) unless value.nil?
          end
        end

        # DateTime coercer
        #
        # @since x.x.x
        # @api private
        #
        # @see Lotus::Model::Coercer
        class DateTime < Coercer
          # Transform a value from the database into a DateTime, unless nil
          #
          # @param value [Object] the object to coerce
          #
          # @return [DateTime] the result of the coercion
          #
          # @raise [TypeError] if the value can't be coerced
          #
          # @since x.x.x
          # @api private
          #
          # @see Lotus::Model::Coercer.load
          # @see http://rdoc.info/gems/lotus-utils/Lotus/Utils/Kernel#DateTime-class_method
          def self.load(value)
            Utils::Kernel.DateTime(value) unless value.nil?
          end
        end

        # Float coercer
        #
        # @since x.x.x
        # @api private
        #
        # @see Lotus::Model::Coercer
        class Float < Coercer
          # Transform a value from the database into a Float, unless nil
          #
          # @param value [Object] the object to coerce
          #
          # @return [Float] the result of the coercion
          #
          # @raise [TypeError] if the value can't be coerced
          #
          # @since x.x.x
          # @api private
          #
          # @see Lotus::Model::Coercer.load
          # @see http://rdoc.info/gems/lotus-utils/Lotus/Utils/Kernel#Float-class_method
          def self.load(value)
            Utils::Kernel.Float(value) unless value.nil?
          end
        end

        # Hash coercer
        #
        # @since x.x.x
        # @api private
        #
        # @see Lotus::Model::Coercer
        class Hash < Coercer
          # Transform a value from the database into a Hash, unless nil
          #
          # @param value [Object] the object to coerce
          #
          # @return [Hash] the result of the coercion
          #
          # @raise [TypeError] if the value can't be coerced
          #
          # @since x.x.x
          # @api private
          #
          # @see Lotus::Model::Coercer.load
          # @see http://rdoc.info/gems/lotus-utils/Lotus/Utils/Kernel#Hash-class_method
          def self.load(value)
            Utils::Kernel.Hash(value) unless value.nil?
          end
        end

        # Integer coercer
        #
        # @since x.x.x
        # @api private
        #
        # @see Lotus::Model::Coercer
        class Integer < Coercer
          # Transform a value from the database into a Integer, unless nil
          #
          # @param value [Object] the object to coerce
          #
          # @return [Integer] the result of the coercion
          #
          # @raise [TypeError] if the value can't be coerced
          #
          # @since x.x.x
          # @api private
          #
          # @see Lotus::Model::Coercer.load
          # @see http://rdoc.info/gems/lotus-utils/Lotus/Utils/Kernel#Integer-class_method
          def self.load(value)
            Utils::Kernel.Integer(value) unless value.nil?
          end
        end

        # BigDecimal coercer
        #
        # @since x.x.x
        # @api private
        #
        # @see Lotus::Model::Coercer
        class BigDecimal < Coercer
          # Transform a value from the database into a BigDecimal, unless nil
          #
          # @param value [Object] the object to coerce
          #
          # @return [BigDecimal] the result of the coercion
          #
          # @raise [TypeError] if the value can't be coerced
          #
          # @since x.x.x
          # @api private
          #
          # @see Lotus::Model::Coercer.load
          # @see http://rdoc.info/gems/lotus-utils/Lotus/Utils/Kernel#BigDecimal-class_method
          def self.load(value)
            Utils::Kernel.BigDecimal(value) unless value.nil?
          end
        end

        # Set coercer
        #
        # @since x.x.x
        # @api private
        #
        # @see Lotus::Model::Coercer
        class Set < Coercer
          # Transform a value from the database into a Set, unless nil
          #
          # @param value [Object] the object to coerce
          #
          # @return [Set] the result of the coercion
          #
          # @raise [TypeError] if the value can't be coerced
          #
          # @since x.x.x
          # @api private
          #
          # @see Lotus::Model::Coercer.load
          # @see http://rdoc.info/gems/lotus-utils/Lotus/Utils/Kernel#Set-class_method
          def self.load(value)
            Utils::Kernel.Set(value) unless value.nil?
          end
        end

        # String coercer
        #
        # @since x.x.x
        # @api private
        #
        # @see Lotus::Model::Coercer
        class String < Coercer
          # Transform a value from the database into a String, unless nil
          #
          # @param value [Object] the object to coerce
          #
          # @return [String] the result of the coercion
          #
          # @raise [TypeError] if the value can't be coerced
          #
          # @since x.x.x
          # @api private
          #
          # @see Lotus::Model::Coercer.load
          # @see http://rdoc.info/gems/lotus-utils/Lotus/Utils/Kernel#String-class_method
          def self.load(value)
            Utils::Kernel.String(value) unless value.nil?
          end
        end

        # Symbol coercer
        #
        # @since x.x.x
        # @api private
        #
        # @see Lotus::Model::Coercer
        class Symbol < Coercer
          # Transform a value from the database into a Symbol, unless nil
          #
          # @param value [Object] the object to coerce
          #
          # @return [Symbol] the result of the coercion
          #
          # @raise [TypeError] if the value can't be coerced
          #
          # @since x.x.x
          # @api private
          #
          # @see Lotus::Model::Coercer.load
          # @see http://rdoc.info/gems/lotus-utils/Lotus/Utils/Kernel#Symbol-class_method
          def self.load(value)
            Utils::Kernel.Symbol(value) unless value.nil?
          end
        end

        # Time coercer
        #
        # @since x.x.x
        # @api private
        #
        # @see Lotus::Model::Coercer
        class Time < Coercer
          # Transform a value from the database into a Time, unless nil
          #
          # @param value [Object] the object to coerce
          #
          # @return [Time] the result of the coercion
          #
          # @raise [TypeError] if the value can't be coerced
          #
          # @since x.x.x
          # @api private
          #
          # @see Lotus::Model::Coercer.load
          # @see http://rdoc.info/gems/lotus-utils/Lotus/Utils/Kernel#Time-class_method
          def self.load(value)
            Utils::Kernel.Time(value) unless value.nil?
          end
        end
      end
    end
  end
end
