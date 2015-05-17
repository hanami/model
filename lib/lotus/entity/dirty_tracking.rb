module Lotus
  module Entity
    # Dirty tracking for entities
    #
    # @since x.x.x
    module DirtyTracking
      # Support dirty tracking
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
      #
      #   article.title = 'Master and Margarita'
      #   article.changed? # => true
      #
      #   article.changed_attributes # => {:title => "Generation P"}

      attr_reader :init_state

      # Override initialize process.
      #
      # @param attributes [Hash] a set of attribute names and values
      #
      # @since x.x.x
      #
      # @see Lotus::Entity#initialize
      def initialize(attributes = {})
        super
        @init_state = _current_state
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
      #   class Article
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
        diff = @init_state.to_a - _current_state.to_a
        Hash[*diff[0]]
      end

      # Checks if the attributes were changed
      #
      # @return [TrueClass, FalseClass] the result of the check
      #
      # @since x.x.x
      def changed?
        !@init_state.eql?(_current_state)
      end

      private

      # Return current state of attributes for Entity
      #
      # @return [::Hash] of attributes
      #
      # @since x.x.x
      #
      # @api private
      def _current_state
        state = {}
        self.class.attributes.each do |attr|
          state.merge!({attr => Marshal.load(Marshal.dump(__send__(attr)))})
        end
        state.freeze
      end
    end
  end
end
