require 'sequel'
require 'sequel/extensions/migration'
require 'pathname'

module Lotus
  module Model
    class MigrationError < ::StandardError
    end

    def self.migration(&blk)
      Sequel.migration(&blk)
    end

    module Migrator
      class Adapter
        def self.for(connection)
          case connection.database_type
          when :sqlite then SQLiteAdapter
          else
            self
          end.new(connection)
        end

        def initialize(connection)
          @connection = connection
        end
      end

      class SQLiteAdapter < Adapter
        def create
          path.dirname.mkpath
          FileUtils.touch(path)
        end

        def drop
          path.delete
        rescue Errno::ENOENT
          raise MigrationError.new("Cannot find database: #{ path.sub(/\A\/\//, '') }")
        end

        private
        def path
          Pathname.new(@connection.uri.sub("#{ @connection.adapter_scheme }:", ''))
        end
      end

      def self.create
        Adapter.for(connection).create
      end

      def self.drop
        Adapter.for(connection).drop
      end

      def self.migrate
        directory = configuration.migrations
        Sequel::Migrator.apply(connection, directory)
      rescue Sequel::Migrator::Error => e
        raise MigrationError.new(e.message)
      end

      private

      def self.connection
        Sequel.connect(
          configuration.adapter.uri
        )
      end

      def self.configuration
        Model.configuration
      end
    end
  end
end
