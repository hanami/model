require 'sequel'
require 'sequel/extensions/migration'
require 'lotus/model/migrator/adapter'

module Lotus
  module Model
    class MigrationError < ::StandardError
    end

    def self.migration(&blk)
      Sequel.migration(&blk)
    end

    module Migrator
      def self.create
        Adapter.for(connection).create
      end

      def self.drop
        Adapter.for(connection).drop
      end

      def self.migrate(version: nil)
        directory = configuration.migrations
        version   = version.to_i unless version.nil?

        Sequel::Migrator.run(connection, directory, target: version)
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
