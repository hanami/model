require_relative 'abstract'

module Hanami
  module Model
    module Sql
      module Consoles
        # PostgreSQL adapter
        #
        # @since x.x.x
        # @api private
        class Postgresql < Abstract
          # @since x.x.x
          # @api private
          COMMAND = 'psql'.freeze

          # @since x.x.x
          # @api private
          PASSWORD = 'PGPASSWORD'.freeze

          # @since x.x.x
          # @api private
          def connection_string
            configure_password
            concat(command, host, database, port, username)
          end

          private

          # @since x.x.x
          # @api private
          def command
            COMMAND
          end

          # @since x.x.x
          # @api private
          def host
            " -h #{@uri.host}"
          end

          # @since x.x.x
          # @api private
          def database
            " -d #{database_name}"
          end

          # @since x.x.x
          # @api private
          def port
            " -p #{@uri.port}" unless @uri.port.nil?
          end

          # @since x.x.x
          # @api private
          def username
            " -U #{@uri.user}" unless @uri.user.nil?
          end

          # @since x.x.x
          # @api private
          def configure_password
            ENV[PASSWORD] = @uri.password unless @uri.password.nil?
          end
        end
      end
    end
  end
end
