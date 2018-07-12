require_relative 'sql'

module Database
  module Strategies
    class Postgresql < Sql
      module JrubyImplementation
        protected

        def load_dependencies
          require 'hanami/model/sql'
          require 'jdbc/postgres'

          Jdbc::Postgres.load_driver
        end

        def export_env
          super
          ENV['HANAMI_DATABASE_URL'] = "jdbc:postgresql://#{host}/#{database_name}"
        end
      end

      module CiImplementation
        protected

        def export_env
          super
          ENV['HANAMI_DATABASE_USERNAME'] = 'postgres' if ENV['TRAVIS']
        end
      end

      def self.eligible?(adapter)
        adapter.start_with?('postgres')
      end

      def initialize
        extend(CiImplementation)    if ci?
        extend(JrubyImplementation) if jruby?
      end

      protected

      def load_dependencies
        require 'hanami/model/sql'
        require 'pg'
      end

      def create_database
        try("Failed to drop Postgres database: #{database_name}") do
          system "dropdb #{database_name}"
        end

        try("Failed to create Postgres database: #{database_name}") do
          system "createdb #{database_name}"
        end
      end

      def export_env
        super
        ENV['HANAMI_DATABASE_TYPE'] = 'postgresql'
        ENV['HANAMI_DATABASE_URL'] = "postgres://#{host}/#{database_name}"
        ENV['HANAMI_DATABASE_USERNAME'] ||= `whoami`.strip.freeze
      end

      private

      def try(message)
        yield
      rescue
        warn message
      end
    end
  end
end
