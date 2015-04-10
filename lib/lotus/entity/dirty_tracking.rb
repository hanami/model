module Lotus
  module Entity
    # Dirty tracking for entities
    #
    # @since x.x.x
    module DirtyTracking
      # Override setters for attributes to support dirty tracking
      #
      # @since x.x.x
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
      #   article.title = 'Master and Margarita'
      #   article.changed? # => true
      #   article.changed_attributes # => {:title => 'Generation P'}
      #
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
        # @since x.x.x
        #
        # @see Lotus::Entity
        #
        # @api private
        def define_attr_accessor(attr)
          attr_reader(attr)
          class_eval %{
            def #{ attr }=(value)
              _attribute_changed(:#{ attr }) if value != @#{ attr }
              @#{ attr } = value
            end
          }
        end
      end

      # Override initialize process.
      # Init @changed_attributes and Clear dirty data if
      # entity persisted.
      #
      # @param attributes [Hash] a set of attribute names and values
      #
      # @since x.x.x
      #
      # @see Lotus::Entity#initialize
      #
      def initialize(attributes = {})
        @changed_attributes = {}
        super
        _clear_changes_information if self.id
      end

      # Getter for hash of changed attributes.
      # Return empty hash, if there is no changes
      # Getter for hash of changed attributes. Value in it is the previous one.
      #
      # @return [::Hash] the changed attributes
      #
      # @since x.x.x
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
      #   article.title = 'Master and Margarita'
      #   article.changed_attributes # => {:title => 'The crime and punishment'}
      #
      def changed_attributes
        @changed_attributes.dup
      end

      # Return boolean of dirty state for model.
      #
      # @return [TrueClass, FalseClass] the changed indicator
      #
      # @since x.x.x
      #
      def changed?
        @changed_attributes.size > 0
      end

      private

      # Set changed attributes in Hash with their old values.
      #
      # @params attrs [Symbol] an attribute name
      #
      # @since x.x.x
      # @api private
      def _attribute_changed(attr)
        @changed_attributes[attr] = __send__(attr)
      end

      # Clear all information about dirty data
      #
      # @since x.x.x
      #
      def _clear_changes_information
        @changed_attributes = {}
      end

    end
  end
end
