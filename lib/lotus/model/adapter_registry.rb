require 'lotus/model/config/adapter'

module Lotus
  module Model
    class AdapterRegistry

      attr_reader :adapter_configs, :adapters

      def initialize
        reset!
      end

      def register(name, uri, default: false)
        adapter = Lotus::Model::Config::Adapter.new(name, uri)
        adapter_configs[name] = adapter
        adapter_configs.default = adapter if default
      end

      def build(mapper)
        adapter_configs.each do |name, config|
          @adapters[name] = config.__send__(:build, mapper)
        end
      end

      def reset!
        @adapter_configs = {}
        @adapters = {}
      end

    end
  end
end
