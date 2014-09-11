require 'lotus/model/adapter_registry'

module Lotus
  module Model
    # Configuration for the framework, models and adapters.
    #
    # Lotus::Model has its own global configuration that can be manipulated
    # via `Lotus::Model.configure`.
    #
    # @since x.x.x
    class Configuration

      extend Forwardable
      delegate :adapters => :adapter_registry

      # @attr_reader mapper [Lotus::Model::Mapper] the persistence mapper
      #
      # @since x.x.x
      attr_reader :mapper

      # @attr_reader mapper [Lotus::Model::AdapterRegistry] a registry of adapter templates
      #
      # @since x.x.x
      attr_reader :adapter_registry

      # Initialize a configuration instance
      #
      # @return [Lotus::Model::Configuration] a new configuration's
      #   instance
      #
      # @since x.x.x
      def initialize
        reset!
      end

      # Reset all the values to the defaults
      #
      # @since x.x.x
      def reset!
        @adapter_registry ||= Lotus::Model::AdapterRegistry.new
        @adapter_registry.reset!
        @mapper = nil
      end

      alias_method :unload!, :reset!

      # Load the configuration for the current framework
      #
      # @since x.x.x
      def load!
        adapter_registry.build(mapper)
        mapper.adapters = adapters
        mapper.load!
      end

      # Register adapter
      #
      # If `default` params is set to `true`, the adapter will be used as default one
      #
      # @param name    [Symbol] Derive adapter class name
      # @param uri     [String] The adapter uri
      # @param default [TrueClass, FalseClass] Decide if adapter is used by default
      #
      # @see Lotus::Model.configure
      # @see Lotus::Model::Config::Adapter
      #
      # @example Register SQL Adapter as default adapter
      #   require 'lotus/model'
      #
      #   Lotus::Model.configure do
      #     adapter :sql, 'postgres://localhost/database', default: true
      #   end
      #
      #   Lotus::Model.adapters.default
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
      #
      # @since x.x.x
      def adapter(name, uri = nil, default: false)
        adapter_registry.register(name, uri, default: default)
      end

      # Set global persistence mapper
      #
      # @see Lotus::Model.configure
      # @see Lotus::Model::Mapper
      #
      # @example Set global persistence mapper
      #   require 'lotus/model'
      #
      #   Lotus::Model.configure do
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
      # @since x.x.x
      def mapping(&blk)
        if block_given?
          @mapper = Lotus::Model::Mapper.new(&blk)
        else
          raise Lotus::Model::InvalidMappingError
        end
      end
    end
  end
end
