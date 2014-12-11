require 'lotus/model/config/adapter'
require 'lotus/model/config/mapper'

module Lotus
  module Model
    # Configuration for the framework, models and adapters.
    #
    # Lotus::Model has its own global configuration that can be manipulated
    # via `Lotus::Model.configure`.
    #
    # @since x.x.x
    class Configuration

      # The persistence mapper
      #
      # @return [Lotus::Model::Mapper]
      #
      # @since x.x.x
      attr_reader :mapper

      # An adapter configuration template
      #
      # @return [Lotus::Model::Config::Adapter]
      #
      # @since x.x.x
      attr_reader :adapter_config

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
        @adapter = nil
        @adapter_config = nil
        @mapper = NullMapper.new
      end

      alias_method :unload!, :reset!

      # Load the configuration for the current framework
      #
      # @return void
      #
      # @since x.x.x
      def load!
        @adapter = adapter_config.build(mapper)
        mapper.load!(@adapter)
      end

      # Register adapter
      #
      # There could only 1 adapter can be registered per application
      #
      # @param @options [Hash] A set of options to register an adapter
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
      # @example Register an adapter
      #   require 'lotus/model'
      #
      #   Lotus::Model.configure do
      #     adapter type: :sql, uri: 'sqlite3://localhost/database'
      #   end
      #
      #   Lotus::Model.adapter_config
      #
      # @since x.x.x
      def adapter(options)
        _check_adapter_options!(options)
        @adapter_config ||= Lotus::Model::Config::Adapter.new(options)
      end

      # Set global persistence mapper
      #
      # @overload mapping(blk)
      #   Specify a set of mapping in the given block
      #   @param blk [Proc] the mapping definitions
      #
      # @overload mapping(path)
      #   Specify a relative path where to find the mapping file
      #   @param path [String] the relative path
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
      # @since 0.2.0
      def mapping(path=nil, &blk)
        if block_given?
          @mapper = Lotus::Model::Mapper.new(&blk)
        elsif path
          _mapping = Lotus::Model::Config::Mapper.new(path)
          @mapper = Lotus::Model::Mapper.new(&_mapping)
        else
          raise Lotus::Model::InvalidMappingError.new('You must specify a block or a file.')
        end
      end

      # Duplicate by copying the settings in a new instance.
      #
      # @return [Lotus::Model::Configuration] a copy of the configuration
      #
      # @since x.x.x
      # @api private
      def duplicate
        Configuration.new.tap do |c|
          c.instance_variable_set(:@adapter_config, @adapter_config)
          c.instance_variable_set(:@mapper, @mapper)
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
        [:type, :uri].each do |keyword|
          raise ArgumentError.new("missing keyword: #{keyword}") if !options.keys.include?(keyword)
        end
      end
    end
  end
end
