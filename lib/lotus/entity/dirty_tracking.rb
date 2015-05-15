module Lotus
  module Entity
    # Dirty tracking for entities
    #
    # @since 0.3.1
    module DirtyTracking
      # Override setters for attributes to support dirty tracking
      #
      # @since 0.3.1
      #
      # @example Dirty tracking
      #   require 'lotus/model'
      #
      #   class User
      #     include Lotus::Entity
      #     include Lotus::Entity::DirtyTracking
      #
      #     attributes :name
      #   end
      #
      #   article = Article.new(title: 'Generation P')
      #   article.changed? # => false
      #
      #   article.title = 'Master and Margarita'
      #   article.changed? # => true
      #
      #   article.changed_attributes # => {:title => "Generation P"}
      def self.included(base)
        base.class_eval do
          extend ClassMethods
        end
      end

      module ClassMethods
        # Override attribute accessors function.
        # Create setter methods with attribute values checking.
        # If the new value or a changed, added to @changed_attributes.
        #
        # @params attr [Symbol] an attribute name
        #
        # @since 0.3.1
        # @api private
        #
        # @see Lotus::Entity::ClassMethods#define_attr_accessor
        def define_attr_accessor(attr)
          attr_reader(attr)

          class_eval %{
            def #{ attr }=(value)
              _attribute_changed(:#{ attr }, @#{ attr }, value)
              @#{ attr } = value
            end
          }
        end
      end

      # Override initialize process.
      #
      # @param attributes [Hash] a set of attribute names and values
      #
      # @since 0.3.1
      #
      # @see Lotus::Entity#initialize
      def initialize(attributes = {})
        _clear_changes_information
        super
        _clear_changes_information
      end

      # Getter for hash of changed attributes.
      # Return empty hash, if there is no changes
      # Getter for hash of changed attributes. Value in it is the previous one.
      #
      # @return [::Hash] the changed attributes
      #
      # @since 0.3.1
      #
      # @example
      #   require 'lotus/model'
      #
      #   class User
      #     include Lotus::Entity
      #     include Lotus::Entity::DirtyTracking
      #
      #     attributes :title
      #   end
      #
      #   article = Article.new(title: 'The crime and punishment')
      #   article.changed_attributes # => {}
      #
      #   article.title = 'Master and Margarita'
      #   article.changed_attributes # => {:title => "The crime and punishment"}
      def changed_attributes
        @changed_attributes.dup
      end

      # Checks if the attributes were changed
      #
      # @return [TrueClass, FalseClass] the result of the check
      #
      # @since 0.3.1
      def changed?
        @changed_attributes.size > 0
      end

      private

      # Set changed attributes in Hash with their old values.
      #
      # @params attrs [Symbol] an attribute name
      #
      # @since 0.3.1
      # @api private
      def _attribute_changed(attr, current_value, new_value)
        @changed_attributes[attr] = new_value if current_value != new_value
      end

      # Clear all information about dirty data
      #
      # @since 0.3.1
      def _clear_changes_information
        @changed_attributes = {}
      end
    end
  end
end
