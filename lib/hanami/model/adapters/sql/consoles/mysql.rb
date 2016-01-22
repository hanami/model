require 'shellwords'
module Hanami
  module Model
    module Adapters
      module Sql
        module Consoles
          class Mysql
            def initialize(uri)
              @uri = uri
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
              " -h #{@uri.host}"
            end

            def database
              " -D #{@uri.path.sub(/^\//, '')}"
            end

            def port
              " -P #{@uri.port}" if @uri.port
            end

            def username
              " -u #{@uri.user}" if @uri.user
            end

            def password
              " -p #{@uri.password}" if @uri.password
            end
          end
        end
      end
    end
  end
end

