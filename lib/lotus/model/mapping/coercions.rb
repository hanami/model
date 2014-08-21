require 'lotus/utils/kernel'

module Lotus
  module Model
    module Mapping
      # Coercions utilities
      #
      # @since 0.1.1
      module Coercions
        # Coerce into an Array, unless the argument is nil
        #
        # @param arg [Object] the object to coerce
        #
        # @return [Array] the result of the coercion
        #
        # @raise [TypeError] if the argument can't be coerced
        #
        # @since 0.1.1
        #
        # @see http://rdoc.info/gems/lotus-utils/Lotus/Utils/Kernel#Array-class_method
        def self.Array(arg)
          Utils::Kernel.Array(arg) unless arg.nil?
        end

        # Coerce into a Boolean, unless the argument is nil
        #
        # @param arg [Object] the object to coerce
        #
        # @return [Boolean] the result of the coercion
        #
        # @raise [TypeError] if the argument can't be coerced
        #
        # @since 0.1.1
        #
        # @see http://rdoc.info/gems/lotus-utils/Lotus/Utils/Kernel#Boolean-class_method
        def self.Boolean(arg)
          Utils::Kernel.Boolean(arg) unless arg.nil?
        end

        # Coerce into a Date, unless the argument is nil
        #
        # @param arg [Object] the object to coerce
        #
        # @return [Date] the result of the coercion
        #
        # @raise [TypeError] if the argument can't be coerced
        #
        # @since 0.1.1
        #
        # @see http://rdoc.info/gems/lotus-utils/Lotus/Utils/Kernel#Date-class_method
        def self.Date(arg)
          Utils::Kernel.Date(arg) unless arg.nil?
        end

        # Coerce into a DateTime, unless the argument is nil
        #
        # @param arg [Object] the object to coerce
        #
        # @return [DateTime] the result of the coercion
        #
        # @raise [TypeError] if the argument can't be coerced
        #
        # @since 0.1.1
        #
        # @see http://rdoc.info/gems/lotus-utils/Lotus/Utils/Kernel#DateTime-class_method
        def self.DateTime(arg)
          Utils::Kernel.DateTime(arg) unless arg.nil?
        end

        # Coerce into a Float, unless the argument is nil
        #
        # @param arg [Object] the object to coerce
        #
        # @return [Float] the result of the coercion
        #
        # @raise [TypeError] if the argument can't be coerced
        #
        # @since 0.1.1
        #
        # @see http://rdoc.info/gems/lotus-utils/Lotus/Utils/Kernel#Float-class_method
        def self.Float(arg)
          Utils::Kernel.Float(arg) unless arg.nil?
        end

        # Coerce into a Hash, unless the argument is nil
        #
        # @param arg [Object] the object to coerce
        #
        # @return [Hash] the result of the coercion
        #
        # @raise [TypeError] if the argument can't be coerced
        #
        # @since 0.1.1
        #
        # @see http://rdoc.info/gems/lotus-utils/Lotus/Utils/Kernel#Hash-class_method
        def self.Hash(arg)
          Utils::Kernel.Hash(arg) unless arg.nil?
        end

        # Coerce into an Integer, unless the argument is nil
        #
        # @param arg [Object] the object to coerce
        #
        # @return [Integer] the result of the coercion
        #
        # @raise [TypeError] if the argument can't be coerced
        #
        # @since 0.1.1
        #
        # @see http://rdoc.info/gems/lotus-utils/Lotus/Utils/Kernel#Integer-class_method
        def self.Integer(arg)
          Utils::Kernel.Integer(arg) unless arg.nil?
        end

        # Coerce into an BigDecimal, unless the argument is nil
        #
        # @param arg [Object] the object to coerce
        #
        # @return [BigDecimal] the result of the coercion
        #
        # @raise [TypeError] if the argument can't be coerced
        #
        # @since x.x.x
        #
        # @see http://rdoc.info/gems/lotus-utils/Lotus/Utils/Kernel#BigDecimal-class_method
        def self.BigDecimal(arg)
          Utils::Kernel.BigDecimal(arg) unless arg.nil?
        end

        # Coerce into a Set, unless the argument is nil
        #
        # @param arg [Object] the object to coerce
        #
        # @return [Set] the result of the coercion
        #
        # @raise [TypeError] if the argument can't be coerced
        #
        # @since 0.1.1
        #
        # @see http://rdoc.info/gems/lotus-utils/Lotus/Utils/Kernel#Set-class_method
        def self.Set(arg)
          Utils::Kernel.Set(arg) unless arg.nil?
        end

        # Coerce into a String, unless the argument is nil
        #
        # @param arg [Object] the object to coerce
        #
        # @return [String] the result of the coercion
        #
        # @raise [TypeError] if the argument can't be coerced
        #
        # @since 0.1.1
        #
        # @see http://rdoc.info/gems/lotus-utils/Lotus/Utils/Kernel#String-class_method
        def self.String(arg)
          Utils::Kernel.String(arg) unless arg.nil?
        end

        # Coerce into a Time, unless the argument is nil
        #
        # @param arg [Object] the object to coerce
        #
        # @return [Time] the result of the coercion
        #
        # @raise [TypeError] if the argument can't be coerced
        #
        # @since 0.1.1
        #
        # @see http://rdoc.info/gems/lotus-utils/Lotus/Utils/Kernel#Time-class_method
        def self.Time(arg)
          Utils::Kernel.Time(arg) unless arg.nil?
        end
      end
    end
  end
end
