require 'lotus/model/config/adapter'
require 'lotus/model/config/mapper'
require 'logger'

module Lotus
  module Model
    # Configuration for the framework, models and adapters.
    #
    # Lotus::Model has its own global configuration that can be manipulated
    # via `Lotus::Model.configure`.
    #
    # @since 0.2.0
    class Configuration

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
      end

      alias_method :unload!, :reset!

      # Load the configuration for the current framework
      #
      # @return void
      #
      # @since 0.2.0
      def load!
        _build_mapper
        build_adapter

        mapper.load!(@adapter)
      end

      # Instantiate adapter from adapter_config
      #
      # @api private
      # @since 0.1.0
      def build_adapter
        @adapter = adapter_config.build(mapper)
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

      # Set the logger
      #
      # @param logger [Logger] the logger instance, default to ::Logger STDOUT
      #
      # @example Set custom logger and retrieve the set logger
      #   require 'lotus/model'
      #
      #   Lotus::Model.configure do
      #     logger ::Logger.new(STDOUT)
      #   end
      #
      #   Lotus::Model.configuration.logger
      #     # => #<Logger:0x007ffc45227920>
      #
      # @since 0.3.0
      # @see Lotus::Model.configure
      def logger(logger = nil)
        if logger.nil?
          @logger ||= _default_logger
        else
          @logger = logger
        end
      end

      # Set directory where migration files should be migrated from
      #
      # @param directory [String] the migration directory filepath
      #
      # @example Set custom logger and retrieve the set logger
      #   require 'lotus/model'
      #
      #   Lotus::Model.configuration.migrations_directory
      #     # => 'db/migrations'
      #
      #   Lotus::Model.configure do
      #     migrations_directory 'my_custom/migrations'
      #   end
      #
      #   Lotus::Model.configuration.migrations_directory
      #     # => 'my_custom/migrations'
      #
      # @since 0.3.0
      # @see Lotus::Model.configure
      def migrations_directory(directory=nil)
        if directory.nil?
          @migrations_directory ||= _default_migrations_directory
        else
          @migrations_directory = directory
        end
      end

      # Return a copy of the configuration of the framework instance associated
      # with the given class.
      #
      # When multiple instances of Lotus::Model are used in the same
      # application, we want to make sure that a model or a migrator will
      # receive the expected configuration.
      #
      # @param base [Class, Module] a model or a migrator
      #
      # @return [Lotus::Model::Configuration] the configuration associated
      #   to the given class.
      #
      # @since 0.3.0
      # @api private
      #
      # @example Direct usage of the framework
      #   require 'lotus/model'
      #
      #   Lotus::Model::Configuration.for(Migrator)
      #     # => will duplicate from Lotus::Model
      #
      # @example Multiple instances of the framework
      #   require 'lotus/model'
      #
      #   module MyApp
      #     module Model
      #       Migrator = ::Lotus::Model::Migrator.duplicate(self)
      #     end
      #   end
      #
      #   Lotus::Model::Configuration.for(Migrator)
      #     # => will duplicate from Lotus::Model
      #
      #   Lotus::Model::Configuration.for(MyApp::Model::Migrator)
      #     # => will duplicate from MyApp::Model
      def self.for(base)
        namespace = Utils::String.new(base).namespace
        framework = Utils::Class.load_from_pattern!("(#{namespace}|Lotus)::Model")
        framework.configuration.duplicate
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
          c.instance_variable_set(:@adapter, @adapter)
          c.instance_variable_set(:@mapper, @mapper)
          c.instance_variable_set(:@logger, @logger)
          c.instance_variable_set(:@migrations_directory, @migrations_directory)
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

      # Default directory that contains migration files
      #
      # @since 0.3.0
      # @api private
      def _default_migrations_directory
        Pathname.pwd.join('db', 'migrations')
      end

      # Default logger to stdlib logger
      #
      # @since 0.3.0
      # @api private
      def _default_logger
        ::Logger.new(STDOUT)
      end
    end
  end
end
