require 'lotus/utils/class_attribute'

module Lotus
  module Model
    module Entity
      def self.included(base)
        base.class_eval do
          extend  ClassMethods
          include Utils::ClassAttribute

          class_attribute :primary_key
          self.primary_key = :id
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

          ([primary_key] + attributes).each do |attr|
            class_eval do
              attr_accessor attr
            end
          end
        end

        def attributes
          @attributes
        end
      end
    end
  end
end

