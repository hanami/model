module Lotus
  module Model
    module Adapters
      module Sql
        module Consoles
          class Mysql
            def initialize(uri, options = {})
              @uri = uri
              @options = options
            end

            def connection_string
              str = 'mysql'
              str << host
              str << database
              str << port if port
              str << username if username
              str << password if password
              str
            end

            private

            def host
              host = @options.fetch('host') { @uri.host }
              " -h #{host}"
            end

            def database
              database = @options.fetch('database') { @uri.path }
              " -D #{database.sub(/^\//, '')}"
            end

            def port
              port = @options.fetch('port') { @uri.port }
              " -P #{port}" if port
            end

            def username
              username = @options.fetch('username') { @uri.user }
              " -u #{username}" if username
            end

            def password
              password = @options.fetch('password') { @uri.password }
              " -p #{password}" if password
            end
          end
        end
      end
    end
  end
end

