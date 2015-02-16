module Lotus
  module Model
    module Adapters
      module Sql
        module Consoles
          class Psql
            def initialize(uri, options = {})
              @uri = uri
              @options = options
            end

            def connection_string
              configure_password
              str = 'psql'
              str << host
              str << database
              str << port if port
              str << username if username
              str
            end

            private

            def host
              host = @options.fetch('host') { @uri.host }
              " -h #{host}"
            end

            def database
              database = @options.fetch('database') { @uri.path }
              " -d #{database.sub(/^\//, '')}"
            end

            def port
              port = @options.fetch('port') { @uri.port }
              " -p #{port}" if port
            end

            def username
              username = @options.fetch('username') { @uri.user }
              " -U #{username}" if username
            end

            def configure_password
              password = @options.fetch('password') { @uri.password }
              ENV['PGPASSWORD'] = password if password
            end
          end
        end
      end
    end
  end
end
