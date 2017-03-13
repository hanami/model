require 'uri'

module Hanami
  module Model
    module Sql
      # SQL console
      #
      # @since 0.7.0
      # @api private
      class Console
        extend Forwardable

        # @since 0.7.0
        # @api private
        def_delegator :console, :connection_string

        # @since 0.7.0
        # @api private
        def initialize(uri)
          @uri = URI.parse(uri)
        end

        private

        # @since 0.7.0
        # @api private
        def console # rubocop:disable Metrics/MethodLength
          case @uri.scheme
          when 'sqlite'
            require 'hanami/model/sql/consoles/sqlite'
            Sql::Consoles::Sqlite.new(@uri)
          when 'postgres', 'postgresql'
            require 'hanami/model/sql/consoles/postgresql'
            Sql::Consoles::Postgresql.new(@uri)
          when 'mysql', 'mysql2'
            require 'hanami/model/sql/consoles/mysql'
            Sql::Consoles::Mysql.new(@uri)
          end
        end
      end
    end
  end
end
