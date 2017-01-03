module Hanami
  module Model
    # Configuration DSL
    #
    # @since 0.7.0
    # @api private
    class Configurator
      # @since 0.7.0
      # @api private
      attr_reader :backend

      # @since 0.7.0
      # @api private
      attr_reader :url

      # @since 0.7.0
      # @api private
      attr_reader :directory

      # @since 0.7.0
      # @api private
      attr_reader :_migrations

      # @since 0.7.0
      # @api private
      attr_reader :_schema

      # @since x.x.x
      # @api private
      attr_reader :callbacks

      # @since 0.7.0
      # @api private
      def self.build(&block)
        new.tap { |config| config.instance_eval(&block) }
      end

      # @since x.x.x
      # @api private
      def initialize
        @callbacks = Hash[before: [], after: []]
      end

      private

      # @since 0.7.0
      # @api private
      def adapter(backend, url)
        @backend = backend
        @url = url
      end

      # @since 0.7.0
      # @api private
      def path(path)
        @directory = path
      end

      # @since 0.7.0
      # @api private
      def migrations(path)
        @_migrations = path
      end

      # @since 0.7.0
      # @api private
      def schema(path)
        @_schema = path
      end

      # @since x.x.x
      # @api private
      def before(&blk)
        callbacks[:before] << blk
      end
    end
  end
end
