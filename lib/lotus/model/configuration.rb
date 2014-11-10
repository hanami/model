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
      delegate adapters: :adapter_registry

      # The persistence mapper
      #
      # @return [Lotus::Model::Mapper]
      #
      # @since x.x.x
      attr_reader :mapper

      # A registry of adapter templates
      #
      # @return [Lotus::Model::AdapterRegistry]
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
      # @return void
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
      # @return void
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
      # @param @options [Hash] A set of options to register an adapter
      # @option options [Symbol] :name Unique adapter name (mandatory)
      # @option options [Symbol] :type The adapter type. Eg. :sql, :memory
      #   (mandatory)
      # @option options [String] :uri The database uri string (mandatory)
      # @option options [TrueClass, FalseClass] :default Set if the current adapter is the
      #   default one for the application scope.
      #
      # @return void
      #
      # @raise [ArgumentError] if one of the mandatory options is omitted
      #
      # @see Lotus::Model.configure
      # @see Lotus::Model::Config::Adapter
      #
      # @example Register SQL Adapter as default adapter
      #   require 'lotus/model'
      #
      #   Lotus::Model.configure do
      #     adapter name: :postgresql, type: :sql, uri: 'postgres://localhost/database', default: true
      #   end
      #
      #   Lotus::Model.adapters.default
      #   Lotus::Model.adapters.fetch(:postgresql)
      #
      # @example Register an adapter
      #   require 'lotus/model'
      #
      #   Lotus::Model.configure do
      #     adapter name: :sqlite3, type: :sql, uri: 'sqlite3://localhost/database'
      #   end
      #
      #   Lotus::Model.adapters.fetch(:sqlite3)
      #
      # @since x.x.x
      def adapter(options)
        _check_adapter_options!(options)
        adapter_registry.register(options)
      end

      # Set global persistence mapper
      #
      # @return void
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

      private

      # @api private
      # @since x.x.x
      #
      # NOTE Drop this manual check when Ruby 2.0 will not be supported anymore.
      #   Use keyword arguments instead.
      def _check_adapter_options!(options)
        # TODO Maybe this is a candidate for Lotus::Utils::Options
        # We already have two similar cases:
        #   1. Lotus::Router :only/:except for RESTful resources
        #   2. Lotus::Validations.validate_options!
        [:name, :type, :uri].each do |keyword|
          raise ArgumentError.new("missing keyword: #{keyword}") if !options.keys.include?(keyword)
        end
      end
    end
  end
end
