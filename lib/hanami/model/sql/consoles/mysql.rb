require_relative 'abstract'

module Hanami
  module Model
    module Sql
      module Consoles
        # MySQL adapter
        #
        # @since 0.7.0
        # @api private
        class Mysql < Abstract
          # @since 0.7.0
          # @api private
          COMMAND = 'mysql'.freeze

          # @since 0.7.0
          # @api private
          def connection_string
            concat(command, host, database, port, username, password)
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
            " -D #{database_name}"
          end

          # @since 0.7.0
          # @api private
          def port
            " -P #{@uri.port}" unless @uri.port.nil?
          end

          # @since 0.7.0
          # @api private
          def username
            " -u #{@uri.user}" unless @uri.user.nil?
          end

          # @since 0.7.0
          # @api private
          def password
            " -p #{@uri.password}" unless @uri.password.nil?
          end
        end
      end
    end
  end
end
