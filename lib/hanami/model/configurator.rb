module Hanami
  module Model
    # Configuration DSL
    #
    # @since x.x.x
    # @api private
    class Configurator
      # @since x.x.x
      # @api private
      attr_reader :backend

      # @since x.x.x
      # @api private
      attr_reader :url

      # @since x.x.x
      # @api private
      attr_reader :directory

      # @since x.x.x
      # @api private
      attr_reader :_migrations

      # @since x.x.x
      # @api private
      attr_reader :_schema

      # @since x.x.x
      # @api private
      def self.build(&block)
        new.tap { |config| config.instance_eval(&block) }
      end

      private

      # @since x.x.x
      # @api private
      def adapter(backend, url)
        @backend = backend
        @url = url
      end

      # @since x.x.x
      # @api private
      def path(path)
        @directory = path
      end

      # @since x.x.x
      # @api private
      def migrations(path)
        @_migrations = path
      end

      # @since x.x.x
      # @api private
      def schema(path)
        @_schema = path
      end
    end
  end
end
