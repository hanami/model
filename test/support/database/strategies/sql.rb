require_relative 'abstract'
require 'hanami/utils/blank'

module Database
  module Strategies
    class Sql < Abstract
      def self.eligible?(_adapter)
        false
      end

      protected

      def export_env
        super
        ENV['HANAMI_DATABASE_ADAPTER'] = 'sql'
      end

      def configure
        Hanami::Model.configure do
          adapter    ENV['HANAMI_DATABASE_ADAPTER'].to_sym, ENV['HANAMI_DATABASE_URL']
          migrations Dir.pwd + '/test/fixtures/database_migrations'
          schema     Dir.pwd + '/tmp/schema.sql'

          before do |connection|
            connection.extension(:pg_enum) if Database.engine?(:postgresql)
          end
        end
      end

      def after
        migrate
        puts "Testing with `#{ENV['HANAMI_DATABASE_ADAPTER']}' adapter (#{ENV['HANAMI_DATABASE_TYPE']}) - jruby: #{jruby?}, ci: #{ci?}"
        puts "Env: #{ENV.inspect}" if ci?
      end

      def migrate
        require 'hanami/model/migrator'
        Hanami::Model::Migrator.migrate
      end

      def credentials
        [ENV['HANAMI_DATABASE_USERNAME'], ENV['HANAMI_DATABASE_PASSWORD']].reject do |token|
          Hanami::Utils::Blank.blank?(token)
        end.join(':')
      end

      def host
        ENV['HANAMI_DATABASE_HOST'] || 'localhost'
      end
    end
  end
end
