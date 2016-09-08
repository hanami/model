module Hanami
  module Model
    class Configurator
      attr_reader :backend
      attr_reader :url
      attr_reader :directory
      attr_reader :_migrations
      attr_reader :_schema

      def self.build(&block)
        self.new.tap { |config| config.instance_eval(&block) }
      end

      private

      def adapter(backend, url)
        @backend = backend
        @url = url
      end

      def path(path)
        @directory = path
      end

      def migrations(path)
        @_migrations = path
      end

      def schema(path)
        @_schema = path
      end
    end
  end
end

