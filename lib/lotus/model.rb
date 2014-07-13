require 'lotus/model/version'
require 'lotus/entity'
require 'lotus/repository'
require 'lotus/model/mapper'

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

    include Utils::ClassAttribute

    Adapter = Struct.new(:name, :uri, :default)

    # Framework adapters
    #
    # @since 0.2.0
    # @api private
    class_attribute :adapters
    self.adapters = {}

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
    #   end
    def self.configure(&block)
      instance_eval(&block)
    end

    # Register adapter
    #
    # If `default` params is set to `true`, the adapter will be used as default one
    #
    # @param name    [Symbol] Derive adapter class name
    # @param uri     [String] The adapter uri
    # @param default [TrueClass,FalseClass] Decide if adapter is used by default
    #
    # @since 0.2.0
    #
    # @see Lotus::Model#adapter
    # @see Lotus::Model#configure
    #
    # @example Register SQL Adapter as default adapter
    #   require 'lotus/model'
    #
    #   Lotus::Model.adapters # => {}
    #
    # @example Register an adapter
    #   require 'lotus/model'
    #
    #   Lotus::Model.configure do
    #     adapter :sql, 'postgres://localhost/database', default: true
    #   end
    def self.adapter(name, uri, default: false)
      adapters[name] = Adapter.new(name, uri, default)
    end
  end
end
