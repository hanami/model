module Lotus
  module Entity
    def self.included(base)
      base.class_eval do
        extend ClassMethods
      end
    end

    module ClassMethods
      def attributes=(*attributes)
        @attributes = attributes
        @attributes.flatten!

        class_eval %{
          def initialize(attributes = {})
        #{ self.attributes.map {|a| "@#{a}" }.join(', ') },_ = *attributes.values_at(#{ self.attributes.map {|a| ":#{a}"}.join(', ') })
          end
        }

        ([:id] + attributes).each do |attr|
          class_eval do
            attr_accessor attr
          end
        end
      end

      def attributes
        @attributes
      end
    end

    def ==(other)
      self.class == other.class &&
         self.id == other.id
    end
  end
end

