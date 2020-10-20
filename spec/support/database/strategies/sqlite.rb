# frozen_string_literal: true
require_relative "sql"
require "pathname"

module Database
  module Strategies
    class Sqlite < Sql
      module JrubyImplementation
        protected

        def load_dependencies
          require "hanami/model/sql"
          require "jdbc/sqlite3"
          Jdbc::SQLite3.load_driver
        end

        def export_env
          super
          ENV["HANAMI_DATABASE_URL"] = "jdbc:sqlite://#{database_name}"
        end
      end

      module CiImplementation
      end

      def self.eligible?(adapter)
        adapter.start_with?("sqlite")
      end

      def initialize
        extend(CiImplementation)    if ci?
        extend(JrubyImplementation) if jruby?
      end

      protected

      def database_name
        Pathname.new(__dir__).join("..", "..", "..", "..", "tmp", "sqlite", "#{super}.sqlite3").to_s
      end

      def load_dependencies
        require "hanami/model/sql"
        require "sqlite3"
      end

      def create_database
        path = Pathname.new(database_name)
        path.dirname.mkpath        # create directory if not exist

        path.delete if path.exist? # delete file if exist
      end

      def export_env
        super
        ENV["HANAMI_DATABASE_TYPE"] = "sqlite"
        ENV["HANAMI_DATABASE_URL"] = "sqlite://#{database_name}"
      end
    end
  end
end
