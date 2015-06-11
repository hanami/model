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
        adapter(connection).create
      end

      def self.drop
        adapter(connection).drop
      end

      def self.migrate(version: nil)
        version = Integer(version) unless version.nil?

        Sequel::Migrator.run(connection, migrations, target: version)
      rescue Sequel::Migrator::Error => e
        raise MigrationError.new(e.message)
      end

      def self.apply
        migrate
        adapter(connection).dump
        delete_migrations
      end

      private

      def self.adapter(connection)
        Adapter.for(connection)
      end

      def self.delete_migrations
        migrations.each_child(&:delete)
      end

      def self.connection
        Sequel.connect(
          configuration.adapter.uri
        )
      end

      def self.configuration
        Model.configuration
      end

      def self.migrations
        configuration.migrations
      end
    end
  end
end
