require 'lotus/model/config/adapter'

module Lotus
  module Model
    # A collection of adapters
    #
    # @since x.x.x
    class AdapterRegistry

      # A hash of adapter config instances
      #
      # @return [Hash<Lotus::Model::Config::Adapter>]
      #
      # @since x.x.x
      attr_reader :adapter_configs

      # A hash of adapter instances
      #
      # @since x.x.x
      attr_reader :adapters

      def initialize
        reset!
      end

      # Register new adapter configuration
      #
      # @param config_key [Symbol] The name that you can use to lookup the
      #   registered adapter
      # @param adapter_name [Symbol] The symbolic name of the adapter.
      # @param uri [String] URI reference to the persistence end point
      # @param default [Boolean] Is this the default adapter for the
      #   application?
      #
      # @return void
      #
      # @see Lotus::Model::Config::Adapter
      # @since x.x.x
      def register(adapter_name, adapter_type, uri, default: false)
        adapter_config = Lotus::Model::Config::Adapter.new(adapter_name, adapter_type, uri)
        adapter_configs[adapter_name] = adapter_config
        adapter_configs.default = adapter_config if !adapter_configs.default || default
      end

      # Instantiate all registered adapters
      #
      # @return void
      #
      # @since x.x.x
      def build(mapper)
        adapter_configs.each do |type, config|
          @adapters[type] = config.__send__(:build, mapper)
          @adapters.default = @adapters[type] if default?(config)
        end
      end

      # Reset all the values to the defaults
      #
      # @return void
      #
      # @since x.x.x
      def reset!
        @adapter_configs = {}
        @adapters = {}
      end

      private

      # Check if the adapter config is default
      #
      # @return [Boolean]
      #
      # @since x.x.x
      # @api private
      def default?(adapter_config)
        adapter_config == adapter_configs.default
      end

    end
  end
end
