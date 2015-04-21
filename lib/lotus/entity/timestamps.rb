module Lotus
  module Entity
    # Timestamps for Entity
    #
    # @since x.x.x
    module Timestamps
      # Override setters/getters for attributes to support timestamps
      #
      # @since x.x.x
      #
      # @example Timestamps for Entity
      #   require 'lotus/model'
      #
      #   class User
      #     include Lotus::Entity
      #     include Lotus::Entity::Timestamps
      #
      #     attributes :name
      #   end
      #
      #   User.attributes => #<Set: {:id, :name, :created_at, :updated_at}>
      def self.included(base)
        base.class_eval do
          attr_accessor(:updated_at, :created_at)
        end
      end
    end
  end
end
