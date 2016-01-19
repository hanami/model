require 'shellwords'
module Hanami
  module Model
    module Adapters
      module Sql
        module Consoles
          class Postgresql
            def initialize(uri)
              @uri = uri
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
              " -h #{@uri.host}"
            end

            def database
              " -d #{@uri.path.sub(/^\//, '')}"
            end

            def port
              " -p #{@uri.port}" if @uri.port
            end

            def username
              " -U #{@uri.user}" if @uri.user
            end

            def configure_password
              ENV['PGPASSWORD'] = @uri.password if @uri.password
            end
          end
        end
      end
    end
  end
end
