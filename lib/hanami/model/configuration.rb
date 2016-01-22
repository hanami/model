require 'hanami/model/config/adapter'
require 'hanami/model/config/mapper'

module Hanami
  module Model
    # Configuration for the framework, models and adapters.
    #
    # Hanami::Model has its own global configuration that can be manipulated
    # via `Hanami::Model.configure`.
    #
    # @since 0.2.0
    class Configuration
      # Default migrations path
      #
      # @since 0.4.0
      # @api private
      #
      # @see Hanami::Model::Configuration#migrations
      DEFAULT_MIGRATIONS_PATH = Pathname.new('db/migrations').freeze

      # Default schema path
      #
      # @since 0.4.0
      # @api private
      #
      # @see Hanami::Model::Configuration#schema
      DEFAULT_SCHEMA_PATH = Pathname.new('db/schema.sql').freeze

      # The persistence mapper
      #
      # @return [Hanami::Model::Mapper]
      #
      # @since 0.2.0
      attr_reader :mapper

      # An adapter configuration template
      #
      # @return [Hanami::Model::Config::Adapter]
      #
      # @since 0.2.0
      attr_reader :adapter_config

      # Initialize a configuration instance
      #
      # @return [Hanami::Model::Configuration] a new configuration's
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
      #   @return [Hanami::Model::Config::Adapter,NilClass] the adapter, if
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
      # @see Hanami::Model.configure
      # @see Hanami::Model::Config::Adapter
      #
      # @example Register the adapter
      #   require 'hanami/model'
      #
      #   Hanami::Model.configure do
      #     adapter type: :sql, uri: 'sqlite3://localhost/database'
      #   end
      #
      #   Hanami::Model.configuration.adapter_config
      #
      # @since 0.2.0
      def adapter(options = nil)
        if options.nil?
          @adapter_config
        else
          _check_adapter_options!(options)
          @adapter_config ||= Hanami::Model::Config::Adapter.new(options)
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
      # @see Hanami::Model.configure
      # @see Hanami::Model::Mapper
      #
      # @example Set global persistence mapper
      #   require 'hanami/model'
      #
      #   Hanami::Model.configure do
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
        @mapper_config = Hanami::Model::Config::Mapper.new(path, &blk)
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
      # @since 0.4.0
      #
      # @see Hanami::Model::Migrations::DEFAULT_MIGRATIONS_PATH
      #
      # @example Set Custom Path
      #   require 'hanami/model'
      #
      #   Hanami::Model.configure do
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
      # @since 0.4.0
      #
      # @see Hanami::Model::Migrations::DEFAULT_SCHEMA_PATH
      #
      # @example Set Custom Path
      #   require 'hanami/model'
      #
      #   Hanami::Model.configure do
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
      # @since 0.4.0
      # @api private
      def root
        Hanami.respond_to?(:root) ? Hanami.root : Pathname.pwd
      end

      # Duplicate by copying the settings in a new instance.
      #
      # @return [Hanami::Model::Configuration] a copy of the configuration
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
      # @see Hanami::Model::Configuration#mapping
      #
      # @api private
      # @since 0.2.0
      def _build_mapper
        @mapper = Hanami::Model::Mapper.new(&@mapper_config) if @mapper_config
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
        # TODO Maybe this is a candidate for Hanami::Utils::Options
        # We already have two similar cases:
        #   1. Hanami::Router :only/:except for RESTful resources
        #   2. Hanami::Validations.validate_options!
        [:type, :uri].each do |keyword|
          raise ArgumentError.new("missing keyword: #{keyword}") if !options.keys.include?(keyword)
        end
      end
    end
  end
end
