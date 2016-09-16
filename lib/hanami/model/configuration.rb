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
      attr_reader :repositories, :mappings

      def initialize(configurator)
        super(configurator.backend, configurator.url)
        @migrations   = configurator._migrations
        @schema       = configurator._schema
        @repositories = []
        @mappings     = {}
      end

      # NOTE: This must be changed when we want to support several adapters at the time
      def url
        environment.gateways[:default].connection.url
      end

      def root
        Hanami.respond_to?(:root) ? Hanami.root : Pathname.pwd
      end

      def migrations
        (@migrations.nil? ? root : root.join(@migrations)).realpath
      end

      def schema
        @schema.nil? ? root : root.join(@schema)
      end

      def define_mappings(root, &blk)
        @mappings[root] = Mapping.new(&blk)
      end
    end
  end
end
