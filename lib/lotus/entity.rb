module Lotus
  module Entity
    def self.included(base)
      base.class_eval do
        extend ClassMethods
      end
    end

    module ClassMethods
      def attributes=(*attributes)
        @attributes = Array(attributes).
          flatten.unshift(:id).uniq

        class_eval %{
          def initialize(attributes = {})
        #{ @attributes.map {|a| "@#{a}" }.join(', ') }, = *attributes.values_at(#{ @attributes.map {|a| ":#{a}"}.join(', ') })
          end
        }

        @attributes.each do |attr|
          class_eval do
            attr_accessor attr
          end
        end
      end

      def attributes
        @attributes
      end
    end

    # @raise NoMethodError
    def initialize(attributes = {})
      attributes.each do |k, v|
        public_send("#{ k }=", v)
      end
    end

    def ==(other)
      self.class == other.class &&
         self.id == other.id
    end
  end
end

