require 'lotus/model/config/adapter'

module Lotus
  module Model
    # A collection of adapters
    #
    # @since x.x.x
    class AdapterRegistry

      # A hash of adapter config instances
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
      # @since x.x.x
      def register(name, uri, default: false)
        adapter_config = Lotus::Model::Config::Adapter.new(name, uri)
        adapter_configs[name] = adapter_config
        adapter_configs.default = adapter_config if !adapter_configs.default || default
      end

      # Instantiate all registered adapters
      #
      # @since x.x.x
      def build(mapper)
        adapter_configs.each do |name, config|
          @adapters[name] = config.__send__(:build, mapper)
          @adapters.default = @adapters[name] if default?(config)
        end
      end

      # Reset all the values to the defaults
      #
      # @since x.x.x
      def reset!
        @adapter_configs = {}
        @adapters = {}
      end

      private

      # Check if the adapter config is default
      #
      # @since x.x.x
      # @api private
      def default?(adapter_config)
        adapter_config == adapter_configs.default
      end

    end
  end
end
