# frozen_string_literal: true

require_relative "sql"

module Database
  module Strategies
    class Postgresql < Sql
      module JrubyImplementation
        protected

        def load_dependencies
          require "hanami/model/sql"
          require "jdbc/postgres"

          Jdbc::Postgres.load_driver
        end

        def export_env
          super
          ENV["HANAMI_DATABASE_URL"] = "jdbc:postgresql://#{host_and_credentials}/#{database_name}"
        end
      end

      module TravisCiImplementation
        protected

        def export_env
          super
          ENV["HANAMI_DATABASE_USERNAME"] = "postgres"
        end
      end

      module CircleCiImplementation
        protected

        def create_database
          try("Failed to drop Postgres database: #{database_name}") do
            system "dropdb --host=#{ENV['HANAMI_DATABASE_HOST']} --username=#{ENV['HANAMI_DATABASE_USERNAME']} --if-exists #{database_name}"
          end

          try("Failed to create Postgres database: #{database_name}") do
            system "createdb --host=#{ENV['HANAMI_DATABASE_HOST']} --username=#{ENV['HANAMI_DATABASE_USERNAME']} #{database_name}"
          end
        end
      end

      module GithubActionsImplementation
        protected

        def export_env
          super
          ENV["HANAMI_DATABASE_HOST"] = "localhost"
          ENV["HANAMI_DATABASE_URL"] = "postgres://#{credentials}@#{host}/#{database_name}"
        end

        def create_database
          try("Failed to drop Postgres database: #{database_name}") do
            system "PGPASSWORD=#{ENV['HANAMI_DATABASE_PASSWORD']} dropdb --host=#{ENV['HANAMI_DATABASE_HOST']} --username=#{ENV['HANAMI_DATABASE_USERNAME']} --if-exists #{database_name}"
          end

          try("Failed to create Postgres database: #{database_name}") do
            system "PGPASSWORD=#{ENV['HANAMI_DATABASE_PASSWORD']} createdb --host=#{ENV['HANAMI_DATABASE_HOST']} --username=#{ENV['HANAMI_DATABASE_USERNAME']} #{database_name}"
          end
        end
      end

      def self.eligible?(adapter)
        adapter.start_with?("postgres")
      end

      def initialize
        ci_implementation = Platform.match do
          ci(:travis) { TravisCiImplementation }
          ci(:circle) { CircleCiImplementation }
          ci(:github) { GithubActionsImplementation }
          default { Module.new }
        end

        extend(ci_implementation)
        extend(JrubyImplementation) if jruby?
      end

      protected

      def load_dependencies
        require "hanami/model/sql"
        require "pg"
      end

      def create_database
        try("Failed to drop Postgres database: #{database_name}") do
          system "dropdb --if-exists #{database_name}"
        end

        try("Failed to create Postgres database: #{database_name}") do
          system "createdb #{database_name}"
        end
      end

      def export_env
        super
        ENV["HANAMI_DATABASE_TYPE"] = "postgresql"
        ENV["HANAMI_DATABASE_USERNAME"] ||= `whoami`.strip.freeze
        ENV["HANAMI_DATABASE_URL"] = "postgres://#{credentials}@#{host}/#{database_name}"
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
