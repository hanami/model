require_relative 'abstract'

module Hanami
  module Model
    module Sql
      module Consoles
        # MySQL adapter
        #
        # @since x.x.x
        # @api private
        class Mysql < Abstract
          # @since x.x.x
          # @api private
          COMMAND = 'mysql'.freeze

          # @since x.x.x
          # @api private
          def connection_string
            concat(command, host, database, port, username, password)
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
            " -D #{database_name}"
          end

          # @since x.x.x
          # @api private
          def port
            " -P #{@uri.port}" unless @uri.port.nil?
          end

          # @since x.x.x
          # @api private
          def username
            " -u #{@uri.user}" unless @uri.user.nil?
          end

          # @since x.x.x
          # @api private
          def password
            " -p #{@uri.password}" unless @uri.password.nil?
          end
        end
      end
    end
  end
end
