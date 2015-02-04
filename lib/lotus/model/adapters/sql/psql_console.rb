module Lotus
  module Model
    module Adapters
      module Sql
        class PsqlConsole
          def initialize(uri, options = {})
            @uri = uri
            @options = options
          end

          def connection_string
            "psql -h #{host} -d #{database} #{port} #{username} #{password}"
          end

          private

          def host
            @options.fetch(:host) { @uri.host }
          end

          def database
            database = @options.fetch('database') { @uri.path }
            database.sub(/^\//, '')
          end

          def port
            port = @options.fetch('port', nil)
            "-p #{port}" if port
          end

          def username
            username = @options.fetch('username', nil)
            "-U #{username}" if username
          end

          def password
            password = @options.fetch('password', nil)
            '-W' if password
          end
        end
      end
    end
  end
end
