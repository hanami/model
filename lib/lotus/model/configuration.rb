module Lotus
  module Model
    # Configuration for the framework, models and adapters.
    #
    # Lotus::Model has its own global configuration that can be manipulated
    # via `Lotus::Model.configure`.
    #
    # @since x.x.x
    class Configuration

      # @attr_reader adapters [Hash] a hash of Lotus::Model::Config::Adapter
      #
      # @since x.x.x
      # @api private
      attr_reader :adapter_configs
      attr_reader :adapters

      # @attr_reader mapper [Lotus::Model::Mapper] the persistence mapper
      #
      # @since x.x.x
      # @api private
      attr_reader :mapper

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
      # @api private
      def reset!
        @adapter_configs = {}
        @adapters = {}
        @mapper = nil
      end

      alias_method :unload!, :reset!

      # Load the configuration for the current framework
      #
      # @since x.x.x
      # @api private
      def load!
        adapter_configs.each do |name, config|
          @adapters[name] = config.__send__(:load!, mapper)
        end
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
      def adapter(name, uri = nil, default: false)
        adapter = Lotus::Model::Config::Adapter.new(name, uri)
        adapter_configs[name] = adapter
        adapter_configs[:default] = adapter if default
      end

      # Set global persistence mapper
      #
      # @since x.x.x
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
      def mapping(&blk)
        @mapper = Lotus::Model::Mapper.new(&blk) if block_given?
      end
    end
  end
end
