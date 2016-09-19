require 'shellwords'

module Hanami
  module Model
    module Sql
      module Consoles
        # PostgreSQL adapter
        #
        # @since x.x.x
        # @api private
        class Postgresql
          # @since x.x.x
          # @api private
          def initialize(uri)
            @uri = uri
          end

          # @since x.x.x
          # @api private
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

          # @since x.x.x
          # @api private
          def host
            " -h #{@uri.host}"
          end

          # @since x.x.x
          # @api private
          def database
            " -d #{@uri.path.sub(/^\//, '')}"
          end

          # @since x.x.x
          # @api private
          def port
            " -p #{@uri.port}" if @uri.port
          end

          # @since x.x.x
          # @api private
          def username
            " -U #{@uri.user}" if @uri.user
          end

          # @since x.x.x
          # @api private
          def configure_password
            ENV['PGPASSWORD'] = @uri.password if @uri.password
          end
        end
      end
    end
  end
end
