require 'lotus/model/version'
require 'lotus/entity'
require 'lotus/repository'
require 'lotus/model/mapper'
require 'lotus/model/configuration'

module Lotus
  # Model
  #
  # @since 0.1.0
  module Model
    # Error for not found entity
    #
    # @since 0.1.0
    #
    # @see Lotus::Repository.find
    class EntityNotFound < ::StandardError
    end

    # Error for non persisted entity
    # It's raised when we try to update or delete a non persisted entity.
    #
    # @since 0.1.0
    #
    # @see Lotus::Repository.update
    class NonPersistedEntityError < ::StandardError
    end

    # Error for invalid mapper configuration
    # It's raised when mapping is not configured correctly
    #
    # @since x.x.x
    #
    # @see Lotus::Configuration#mapping
    class InvalidMappingError < ::StandardError
    end

    include Utils::ClassAttribute

    # Framework configuration
    #
    # @since 0.2.0
    # @api private
    class_attribute :configuration
    self.configuration = Configuration.new

    # Configure the framework.
    # It yields the given block in the context of the configuration
    #
    # @param blk [Proc] the configuration block
    #
    # @since 0.2.0
    #
    # @see Lotus::Model
    #
    # @example
    #   require 'lotus/model'
    #
    #   Lotus::Model.configure do
    #     adapter :sql, 'postgres://localhost/database', default: true
    #
    #     mapping do
    #       collection :users do
    #         entity User
    #
    #         attribute :id,   Integer
    #         attribute :name, String
    #       end
    #     end
    #   end
    #
    # By convention, Lotus inflects adapter name to find the adapter class
    # The above example has name :sql, thus derived class will be `Lotus::Model::Adapters::SqlAdapter`
    #
    # Custom adapter class can be configured via `class_name` option
    #
    # @example
    #   require 'lotus/model'
    #
    #   Lotus::Model.configure do
    #     adapter :sql, 'postgres://localhost/database', class_name: 'UberSqlAdapter'
    #   end
    #
    # which would load `Lotus::Model::Adapters::UberSqlAdapter`
    def self.configure(&block)
      configuration.instance_eval(&block)
    end

    # Load the framework
    #
    # @since x.x.x
    # @api private
    def self.load!
      configuration.load!
    end

    # Unload the framework
    #
    # @since x.x.x
    # @api private
    def self.unload!
      configuration.unload!
    end

  end
end
