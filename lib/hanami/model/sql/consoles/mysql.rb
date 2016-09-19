require 'shellwords'

module Hanami
  module Model
    module Sql
      module Consoles
        # MySQL adapter
        #
        # @since x.x.x
        # @api private
        class Mysql
          # @since x.x.x
          # @api private
          def initialize(uri)
            @uri = uri
          end

          # @since x.x.x
          # @api private
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

          # @since x.x.x
          # @api private
          def host
            " -h #{@uri.host}"
          end

          # @since x.x.x
          # @api private
          def database
            " -D #{@uri.path.sub(/^\//, '')}"
          end

          # @since x.x.x
          # @api private
          def port
            " -P #{@uri.port}" if @uri.port
          end

          # @since x.x.x
          # @api private
          def username
            " -u #{@uri.user}" if @uri.user
          end

          # @since x.x.x
          # @api private
          def password
            " -p #{@uri.password}" if @uri.password
          end
        end
      end
    end
  end
end
