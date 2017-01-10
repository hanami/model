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
      # @since 0.7.0
      # @api private
      attr_reader :mappings

      # @since 0.7.0
      # @api private
      attr_reader :entities

      # @since x.x.x
      # @api private
      attr_reader :logger

      # @since x.x.x
      # @api private
      attr_reader :migrations_logger

      # @since 0.2.0
      # @api private
      def initialize(configurator)
        super(configurator.backend, configurator.url)
        @migrations        = configurator._migrations
        @schema            = configurator._schema
        @logger            = configurator._logger
        @migrations_logger = configurator._migrations_logger
        @mappings          = {}
        @entities          = {}
      end

      # NOTE: This must be changed when we want to support several adapters at the time
      #
      # @since 0.7.0
      # @api private
      def url
        connection.url
      end

      # NOTE: This must be changed when we want to support several adapters at the time
      #
      # @since 0.7.0
      # @api private
      def connection
        gateway.connection
      end

      # NOTE: This must be changed when we want to support several adapters at the time
      #
      # @since 0.7.0
      # @api private
      def gateway
        environment.gateways[:default]
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

      # @since 0.7.0
      # @api private
      def define_mappings(root, &blk)
        @mappings[root] = Mapping.new(&blk)
      end

      # @since 0.7.0
      # @api private
      def register_entity(plural, singular, klass)
        @entities[plural]   = klass
        @entities[singular] = klass
      end

      # @since 0.7.0
      # @api private
      def define_entities_mappings(container, repositories)
        return unless defined?(Sql::Entity::Schema)

        repositories.each do |r|
          relation = r.relation
          entity   = r.entity

          entity.schema = Sql::Entity::Schema.new(entities, container.relations[relation], mappings.fetch(relation))
        end
      end
    end
  end
end
