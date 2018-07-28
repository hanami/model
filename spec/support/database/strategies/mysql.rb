# frozen_string_literal: true

require_relative "sql"

module Database
  module Strategies
    class Mysql < Sql
      module JrubyImplementation
        protected

        def load_dependencies
          require "hanami/model/sql"
          require "jdbc/mysql"
        end

        def export_env
          super
          ENV["HANAMI_DATABASE_URL"] = "jdbc:mysql://#{host}/#{database_name}?#{credentials}"
        end

        def host
          ENV["HANAMI_DATABASE_HOST"] || "127.0.0.1"
        end

        def credentials
          Hash[
            "user"     => ENV["HANAMI_DATABASE_USERNAME"],
            "password" => ENV["HANAMI_DATABASE_PASSWORD"],
            "useSSL"   => "false"
          ].map do |key, value|
            "#{key}=#{value}" unless Hanami::Utils::Blank.blank?(value)
          end.compact.join("&")
        end
      end

      module TravisCiImplementation
        protected

        def export_env
          super
          ENV["HANAMI_DATABASE_USERNAME"] = "travis"
          ENV["HANAMI_DATABASE_URL"] = "mysql2://#{credentials}@#{host}/#{database_name}"
        end

        def create_database
          super
          run_command "GRANT ALL PRIVILEGES ON *.* TO '#{ENV['HANAMI_DATABASE_USERNAME']}'@'#{host}'; FLUSH PRIVILEGES;"
          run_command "GRANT ALL PRIVILEGES ON *.* TO '#{ENV['HANAMI_DATABASE_USERNAME']}'@'%'; FLUSH PRIVILEGES;" if jruby?
        end

        private

        def run_command(command)
          result = system %(mysql -u root -e "#{command}")
          raise "Failed command:\n#{command}" unless result
        end
      end

      module CircleCiImplementation
        protected

        def export_env
          super
          ENV["HANAMI_DATABASE_USERNAME"] ||= "root"
          ENV["HANAMI_DATABASE_URL"] = "mysql2://#{credentials}@#{host}/#{database_name}"
        end

        def create_database
          run_command "DROP DATABASE IF EXISTS #{database_name}"
          run_command "CREATE DATABASE #{database_name}"
        end

        private

        def run_command(command)
          result = system %(mysql -h #{host} -u #{ENV['HANAMI_DATABASE_USERNAME']} --password=#{ENV['HANAMI_DATABASE_PASSWORD']} -e "#{command}")
          raise "Failed command:\n#{command}" unless result
        end
      end

      def self.eligible?(adapter)
        adapter.start_with?("mysql")
      end

      def initialize
        ci_implementation = Platform.match do
          ci(:travis) { TravisCiImplementation }
          ci(:circle) { CircleCiImplementation }
          default { Module.new }
        end

        extend(ci_implementation)
        extend(JrubyImplementation) if jruby?
      end

      protected

      def load_dependencies
        require "hanami/model/sql"
        require "mysql2"
      end

      def export_env
        super
        ENV["HANAMI_DATABASE_TYPE"] = "mysql"
        ENV["HANAMI_DATABASE_USERNAME"] ||= "root"
        ENV["HANAMI_DATABASE_PASSWORD"] ||= ""
        ENV["HANAMI_DATABASE_URL"] = "mysql2://#{credentials}@#{host}/#{database_name}"
      end

      def create_database
        run_command "DROP DATABASE IF EXISTS #{database_name}"
        run_command "CREATE DATABASE #{database_name}"
        run_command "GRANT ALL PRIVILEGES ON #{database_name}.* TO '#{ENV['HANAMI_DATABASE_USERNAME']}'@'#{host}'; FLUSH PRIVILEGES;"
      end

      private

      def run_command(command)
        system %(mysql -u #{ENV['HANAMI_DATABASE_USERNAME']} -e "#{command}")
      end
    end
  end
end
