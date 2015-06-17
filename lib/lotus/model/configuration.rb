require 'lotus/model/config/adapter'
require 'lotus/model/config/mapper'

module Lotus
  module Model
    # Configuration for the framework, models and adapters.
    #
    # Lotus::Model has its own global configuration that can be manipulated
    # via `Lotus::Model.configure`.
    #
    # @since 0.2.0
    class Configuration
      # Default migrations path
      #
      # @since x.x.x
      # @api private
      #
      # @see Lotus::Model::Configuration#migrations
      DEFAULT_MIGRATIONS_PATH = Pathname.new('db/migrations').freeze

      # Default schema path
      #
      # @since x.x.x
      # @api private
      #
      # @see Lotus::Model::Configuration#schema
      DEFAULT_SCHEMA_PATH = Pathname.new('db/schema.sql').freeze

      # The persistence mapper
      #
      # @return [Lotus::Model::Mapper]
      #
      # @since 0.2.0
      attr_reader :mapper

      # An adapter configuration template
      #
      # @return [Lotus::Model::Config::Adapter]
      #
      # @since 0.2.0
      attr_reader :adapter_config

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
      # @return void
      #
      # @since 0.2.0
      def reset!
        @adapter = nil
        @adapter_config = nil
        @mapper = NullMapper.new
        @mapper_config = nil
        @migrations = DEFAULT_MIGRATIONS_PATH
        @schema = DEFAULT_SCHEMA_PATH
      end

      alias_method :unload!, :reset!

      # Load the configuration for the current framework
      #
      # @return void
      #
      # @since 0.2.0
      def load!
        _build_mapper
        _build_adapter

        mapper.load!(@adapter)
      end

      # Register adapter
      #
      # There could only 1 adapter can be registered per application
      #
      # @overload adapter
      #   Retrieves the configured adapter
      #   @return [Lotus::Model::Config::Adapter,NilClass] the adapter, if
      #     present
      #
      # @overload adapter
      #   Register the adapter
      #     @param @options [Hash] A set of options to register an adapter
      #     @option options [Symbol] :type The adapter type. Eg. :sql, :memory
      #       (mandatory)
      #     @option options [String] :uri The database uri string (mandatory)
      #
      # @return void
      #
      # @raise [ArgumentError] if one of the mandatory options is omitted
      #
      # @see Lotus::Model.configure
      # @see Lotus::Model::Config::Adapter
      #
      # @example Register the adapter
      #   require 'lotus/model'
      #
      #   Lotus::Model.configure do
      #     adapter type: :sql, uri: 'sqlite3://localhost/database'
      #   end
      #
      #   Lotus::Model.configuration.adapter_config
      #
      # @since 0.2.0
      def adapter(options = nil)
        if options.nil?
          @adapter_config
        else
          _check_adapter_options!(options)
          @adapter_config ||= Lotus::Model::Config::Adapter.new(options)
        end
      end

      # Set global persistence mapping
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
        @mapper_config = Lotus::Model::Config::Mapper.new(path, &blk)
      end

      # Migrations directory
      #
      # It defaults to <tt>db/migrations</tt>.
      #
      # @overload migrations
      #   Get migrations directory
      #   @return [Pathname] migrations directory
      #
      # @overload migrations(path)
      #   Set migrations directory
      #   @param path [String,Pathname] the path
      #   @raise [Errno::ENOENT] if the given path doesn't exist
      #
      # @since x.x.x
      #
      # @see Lotus::Model::Migrations::DEFAULT_MIGRATIONS_PATH
      #
      # @example Set Custom Path
      #   require 'lotus/model'
      #
      #   Lotus::Model.configure do
      #     # ...
      #     migrations 'path/to/migrations'
      #   end
      def migrations(path = nil)
        if path.nil?
          @migrations
        else
          @migrations = root.join(path).realpath
        end
      end

      # Schema
      #
      # It defaults to <tt>db/schema.sql</tt>.
      #
      # @overload schema
      #   Get schema path
      #   @return [Pathname] schema path
      #
      # @overload schema(path)
      #   Set schema path
      #   @param path [String,Pathname] the path
      #
      # @since x.x.x
      #
      # @see Lotus::Model::Migrations::DEFAULT_SCHEMA_PATH
      #
      # @example Set Custom Path
      #   require 'lotus/model'
      #
      #   Lotus::Model.configure do
      #     # ...
      #     schema 'path/to/schema.sql'
      #   end
      def schema(path = nil)
        if path.nil?
          @schema
        else
          @schema = root.join(path)
        end
      end

      # Root directory
      #
      # @since x.x.x
      # @api private
      def root
        Lotus.respond_to?(:root) ? Lotus.root : Pathname.pwd
      end

      # Duplicate by copying the settings in a new instance.
      #
      # @return [Lotus::Model::Configuration] a copy of the configuration
      #
      # @since 0.2.0
      # @api private
      def duplicate
        Configuration.new.tap do |c|
          c.instance_variable_set(:@adapter_config, @adapter_config)
          c.instance_variable_set(:@mapper, @mapper)
        end
      end

      private

      # Instantiate mapper from mapping block
      #
      # @see Lotus::Model::Configuration#mapping
      #
      # @api private
      # @since 0.2.0
      def _build_mapper
        @mapper = Lotus::Model::Mapper.new(&@mapper_config.to_proc) if @mapper_config
      end

      # @api private
      # @since 0.1.0
      def _build_adapter
        @adapter = adapter_config.build(mapper)
      end

      # @api private
      # @since 0.2.0
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
