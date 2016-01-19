module Hanami
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

          call_db_command('createdb') do |error_message|
            message = if error_message.match(/already exists/)
              "createdb: database creation failed. There is 1 other session using the database."
            else
              error_message
            end

            raise MigrationError.new(message)
          end
        end

        # @since 0.4.0
        # @api private
        def drop
          set_environment_variables

          call_db_command('dropdb') do |error_message|
            message = if error_message.match(/does not exist/)
              "Cannot find database: #{ database }"
            else
              error_message
            end

            raise MigrationError.new(message)
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

        # @since 0.5.1
        # @api private
        def call_db_command(command)
          require 'open3'

          begin
            Open3.popen3(command, database) do |stdin, stdout, stderr, wait_thr|
              unless wait_thr.value.success? # wait_thr.value is the exit status
                yield stderr.read
              end
            end
          rescue SystemCallError => e
            yield e.message
          end
        end
      end
    end
  end
end
