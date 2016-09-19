require 'rom/configuration'

module Hanami
  module Model
    # Configuration for the framework, models and adapters.
    #
    # Hanami::Model has its own global configuration that can be manipulated
    # via `Hanami::Model.configure`.
    #
    # @since 0.2.0
    class Configuration < ROM::Configuration
      # @since x.x.x
      # @api private
      attr_reader :repositories

      # @since x.x.x
      # @api private
      attr_reader :mappings

      # @since 0.2.0
      # @api private
      def initialize(configurator)
        super(configurator.backend, configurator.url)
        @migrations   = configurator._migrations
        @schema       = configurator._schema
        @repositories = []
        @mappings     = {}
      end

      # NOTE: This must be changed when we want to support several adapters at the time
      #
      # @since x.x.x
      # @api private
      def url
        environment.gateways[:default].connection.url
      end

      # Root directory
      #
      # @since 0.4.0
      # @api private
      def root
        Hanami.respond_to?(:root) ? Hanami.root : Pathname.pwd
      end

      # Migrations directory
      #
      # @since 0.4.0
      def migrations
        (@migrations.nil? ? root : root.join(@migrations)).realpath
      end

      # Path for schema dump file
      #
      # @since 0.4.0
      def schema
        @schema.nil? ? root : root.join(@schema)
      end

      # @since x.x.x
      # @api private
      def define_mappings(root, &blk)
        @mappings[root] = Mapping.new(&blk)
      end
    end
  end
end
