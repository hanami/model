module Lotus
  module Model
    # Configuration for the framework, models and adapters.
    #
    # Lotus::Model has its own global configuration that can be manipulated
    # via `Lotus::Model.configure`.
    #
    # @since 0.2.0
    class Configuration

      # @attr_reader adapters [Hash] a hash of Lotus::Model::Config::Adapter
      #
      # @since 0.2.0
      #
      # @see Lotus::Model::Configuration#adapters
      attr_reader :adapters

      # Initialize a configuration instance
      #
      # @return [Lotus::Model::Configuration] a new configuration's
      #   instance
      #
      # @since 0.2.0
      def initialize
        reset!
      end

      # Reset all the values to the defaults
      #
      # @since 0.2.0
      # @api private
      def reset!
        @adapters = {}
      end

      # Register adapter
      #
      # If `default` params is set to `true`, the adapter will be used as default one
      #
      # @param name    [Symbol] Derive adapter class name
      # @param uri     [String] The adapter uri
      # @param default [TrueClass, FalseClass] Decide if adapter is used by default
      #
      # @since x.x.x
      #
      # @see Lotus::Model#configure
      #
      # @example Register SQL Adapter as default adapter
      #   require 'lotus/model'
      #
      #   Lotus::Model.configure do
      #     adapter :sql, 'postgres://localhost/database', default: true
      #   end
      #
      #   Lotus::Model.adapters.fetch(:default)
      #   Lotus::Model.adapters.fetch(:sql)
      #
      # @example Register an adapter
      #   require 'lotus/model'
      #
      #   Lotus::Model.configure do
      #     adapter :sql, 'postgres://localhost/database'
      #   end
      #
      #   Lotus::Model.adapters.fetch(:sql)
      def adapter(name, uri, default: false)
        adapter = Lotus::Model::Config::Adapter.new(name, uri)
        @adapters[name] = adapter
        @adapters[:default] = adapter if default
      end
    end
  end
end
