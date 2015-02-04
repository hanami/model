module Lotus
  module Model
    module Adapters
      module Sql
        class MysqlConsole
          def initialize(uri, options = {})
            @uri = uri
            @options = options
          end

          def connection_string
            "mysql -h #{host} -D #{database} #{port} #{username} #{password}"
          end

          private

          def host
            @options.fetch('host') { @uri.host }
          end

          def database
            database = @options.fetch('database') { @uri.path }
            database.sub(/^\//, '')
          end

          def port
            port = @options.fetch('port', nil)
            "-P #{port}" if port
          end

          def username
            username = @options.fetch('username', nil)
            "-u #{username}" if username
          end

          def password
            password = @options.fetch('password', nil)
            "-p #{password}" if password
          end
        end
      end
    end
  end
end

