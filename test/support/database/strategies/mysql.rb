require_relative 'sql'

module Database
  module Strategies
    class Mysql < Sql
      module JrubyImplementation
        protected

        def load_dependencies
          require 'hanami/model/sql'
          require 'jdbc/mysql'
        end

        def export_env
          super
          ENV['HANAMI_DATABASE_URL'] = "jdbc:mysql://#{ENV['HANAMI_DATABASE_USERNAME']}:#{ENV['HANAMI_DATABASE_PASSWORD']}@localhost/#{database_name}?useSSL=false"
        end
      end

      module CiImplementation
        protected

        def export_env
          super
          ENV['HANAMI_DATABASE_USERNAME'] = 'travis'
        end

        private

        def run_command(command)
          result = system %(mysql -u root -e "#{command}")
          raise "Failed command:\n#{command}" unless result
        end
      end

      def self.eligible?(adapter)
        adapter.start_with?('mysql')
      end

      def initialize
        extend(CiImplementation)    if ci?
        extend(JrubyImplementation) if jruby?
      end

      protected

      def load_dependencies
        require 'hanami/model/sql'
        require 'mysql2'
      end

      def export_env
        super
        ENV['HANAMI_DATABASE_TYPE']       = 'mysql'
        ENV['HANAMI_DATABASE_USERNAME'] ||= 'root'
        ENV['HANAMI_DATABASE_PASSWORD'] ||= ''
        ENV['HANAMI_DATABASE_URL']        = "mysql2://#{ENV['HANAMI_DATABASE_USERNAME']}:#{ENV['HANAMI_DATABASE_PASSWORD']}@localhost/#{database_name}"
      end

      def create_database
        run_command "DROP DATABASE IF EXISTS #{database_name}"
        run_command "CREATE DATABASE #{database_name}"
        run_command "GRANT ALL PRIVILEGES ON #{database_name}.* TO '#{ENV['HANAMI_DATABASE_USERNAME']}'@'localhost'; FLUSH PRIVILEGES;"
      end

      private

      def run_command(command)
        system %(mysql -u #{ENV['HANAMI_DATABASE_USERNAME']} -e "#{command}")
      end
    end
  end
end
