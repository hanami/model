require_relative 'abstract'
require 'cgi'

module Hanami
  module Model
    module Sql
      module Consoles
        # PostgreSQL adapter
        #
        # @since 0.7.0
        # @api private
        class Postgresql < Abstract
          # @since 0.7.0
          # @api private
          COMMAND = 'psql'.freeze

          # @since 0.7.0
          # @api private
          PASSWORD = 'PGPASSWORD'.freeze

          # @since 0.7.0
          # @api private
          def connection_string
            configure_password
            concat(command, host, database, port, username)
          end

          private

          # @since 0.7.0
          # @api private
          def command
            COMMAND
          end

          # @since 0.7.0
          # @api private
          def host
            " -h #{query['host'] || @uri.host}"
          end

          # @since 0.7.0
          # @api private
          def database
            " -d #{database_name}"
          end

          # @since 0.7.0
          # @api private
          def port
            port = query['port'] || @uri.port
            " -p #{port}" if port
          end

          # @since 0.7.0
          # @api private
          def username
            username = query['user'] || @uri.user
            " -U #{username}" if username
          end

          # @since 0.7.0
          # @api private
          def configure_password
            password = query['password'] || @uri.password
            ENV[PASSWORD] = CGI.unescape(query['password'] || @uri.password) if password
          end

          # @since 1.1.0
          # @api private
          def query
            return {} if @uri.query.nil? || @uri.query.empty?

            parsed_query = @uri.query.split("&").map { |a| a.split("=") }
            @query ||= Hash[parsed_query]
          end
        end
      end
    end
  end
end
