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
            " -h #{query['host'] || @uri.host}"
          end

          # @since 0.7.0
          # @api private
          def database
            " -D #{database_name}"
          end

          # @since 0.7.0
          # @api private
          def port
            port = query['port'] || @uri.port
            " -P #{port}" if port
          end

          # @since 0.7.0
          # @api private
          def username
            username = query['user'] || @uri.user
            " -u #{username}" if username
          end

          # @since 0.7.0
          # @api private
          def password
            password = query['password'] || @uri.password
            " -p #{password}" if password
          end

          # @since x.x.x
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
