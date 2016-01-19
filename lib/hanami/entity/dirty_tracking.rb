module Hanami
  module Entity
    # Dirty tracking for entities
    #
    # @since 0.3.1
    #
    # @example Dirty tracking
    #   require 'hanami/model'
    #
    #   class User
    #     include Hanami::Entity
    #     include Hanami::Entity::DirtyTracking
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
    module DirtyTracking
      # Override initialize process.
      #
      # @param attributes [Hash] a set of attribute names and values
      #
      # @since 0.3.1
      #
      # @see Hanami::Entity#initialize
      def initialize(attributes = {})
        super
        @_initial_state = Utils::Hash.new(to_h).deep_dup
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
      #   require 'hanami/model'
      #
      #   class Article
      #     include Hanami::Entity
      #     include Hanami::Entity::DirtyTracking
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
        Hash[@_initial_state.to_a - to_h.to_a]
      end

      # Checks if the attributes were changed
      #
      # @return [TrueClass, FalseClass] the result of the check
      #
      # @since 0.3.1
      def changed?
        changed_attributes.any?
      end
    end
  end
end
