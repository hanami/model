module Lotus
  module Model
    module Migrator
      # PostgreSQL adapter
      #
      # @since 0.4.0
      # @api private
      class PostgresAdapter < Adapter
        # @since 0.4.0
        # @api private
        HOST     = 'PGHOST'.freeze

        # @since 0.4.0
        # @api private
        PORT     = 'PGPORT'.freeze

        # @since 0.4.0
        # @api private
        USER     = 'PGUSER'.freeze

        # @since 0.4.0
        # @api private
        PASSWORD = 'PGPASSWORD'.freeze

        # @since 0.4.0
        # @api private
        def create
          set_environment_variables
          `createdb #{ database }`
        end

        # @since 0.4.0
        # @api private
        def drop
          set_environment_variables

          require 'open3'

          Open3.popen3('dropdb', database) do |stdin, stdout, stderr, wait_thr|
            exit_status = wait_thr.value

            unless exit_status.success?
              error_message = stderr.read

              message = if error_message.match(/does not exist/)
                "Cannot find database: #{ database }"
              else
                error_message
              end

              raise MigrationError.new(message)
            end
          end
        end

        # @since 0.4.0
        # @api private
        def dump
          set_environment_variables
          dump_structure
          dump_migrations_data
        end

        # @since 0.4.0
        # @api private
        def load
          set_environment_variables
          load_structure
        end

        private

        # @since 0.4.0
        # @api private
        def set_environment_variables
          ENV[HOST]     = host      unless host.nil?
          ENV[PORT]     = port.to_s unless port.nil?
          ENV[PASSWORD] = password  unless password.nil?
          ENV[USER]     = username  unless username.nil?
        end

        # @since 0.4.0
        # @api private
        def dump_structure
          system "pg_dump -i -s -x -O -T #{ migrations_table } -f #{ escape(schema) } #{ database }"
        end

        # @since 0.4.0
        # @api private
        def load_structure
          system "psql -X -q -f #{ escape(schema) } #{ database }" if schema.exist?
        end

        # @since 0.4.0
        # @api private
        def dump_migrations_data
          system "pg_dump -t #{ migrations_table } #{ database } >> #{ escape(schema) }"
        end
      end
    end
  end
end
