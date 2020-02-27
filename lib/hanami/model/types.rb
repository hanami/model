# frozen_string_literal: true

require "rom/types"

module Hanami
  module Model
    # Types definitions
    #
    # @since 0.7.0
    module Types
      include ROM::Types

      # @since 0.7.0
      # @api private
      def self.included(mod)
        mod.extend(ClassMethods)
      end

      # Class level interface
      #
      # @since 0.7.0
      # rubocop:disable Naming/MethodName
      module ClassMethods
        # Define an entity of the given type
        #
        # @param type [Hanami::Entity] an entity
        #
        # @since 1.1.0
        #
        # @example
        #   require "hanami/model"
        #
        #   class Account < Hanami::Entity
        #     # ...
        #     attribute :owner, Types::Entity(User)
        #   end
        #
        #   account = Account.new(owner: User.new(name: "Luca"))
        #   account.owner.class # => User
        #   account.owner.name  # => "Luca"
        #
        #   account = Account.new(owner: { name: "MG" })
        #   account.owner.class # => User
        #   account.owner.name  # => "MG"
        def Entity(type)
          Hanami::Model::Types.Constructor(type).optional
        end

        # Define an array of given type
        #
        # @param type [Object] an object
        #
        # @since 0.7.0
        #
        # @example
        #   require "hanami/model"
        #
        #   class Account < Hanami::Entity
        #     attributes do
        #       # ...
        #       attribute :users, Types::Collection(User)
        #     end
        #   end
        #
        #   account = Account.new(users: [User.new(name: "Luca")])
        #   user    = account.users.first
        #   user.class # => User
        #   user.name  # => "Luca"
        #
        #   account = Account.new(users: [{ name: "MG" }])
        #   user    = account.users.first
        #   user.class # => User
        #   user.name  # => "MG"
        def Collection(type)
          Hanami::Model::Types.Array(type)
        end
      end
      # rubocop:enable Naming/MethodName
    end
  end
end
