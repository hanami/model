require 'uri'

module Hanami
  module Model
    module Sql
      # SQL console
      #
      # @since x.x.x
      # @api private
      class Console
        extend Forwardable

        def_delegator :console, :connection_string

        # @since x.x.x
        # @api private
        def initialize(uri)
          @uri = URI.parse(uri)
        end

        private

        # @since x.x.x
        # @api private
        def console # rubocop:disable Metrics/MethodLength
          case @uri.scheme
          when 'sqlite'
            require 'hanami/model/sql/consoles/sqlite'
            Sql::Consoles::Sqlite.new(@uri)
          when 'postgres'
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
