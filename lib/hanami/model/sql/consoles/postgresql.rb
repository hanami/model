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
            " -h #{@uri.host}"
          end

          # @since 0.7.0
          # @api private
          def database
            " -d #{database_name}"
          end

          # @since 0.7.0
          # @api private
          def port
            " -p #{@uri.port}" unless @uri.port.nil?
          end

          # @since 0.7.0
          # @api private
          def username
            " -U #{@uri.user}" unless @uri.user.nil?
          end

          # @since 0.7.0
          # @api private
          def configure_password
            ENV[PASSWORD] = CGI.unescape(@uri.password) unless @uri.password.nil?
          end
        end
      end
    end
  end
end
