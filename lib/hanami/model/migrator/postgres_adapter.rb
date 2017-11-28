module Hanami
  module Model
    class Migrator
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

        # @since 1.0.0
        # @api private
        DB_CREATION_ERROR = 'createdb: database creation failed. If the database exists, ' \
                            'then its console may be open. See this issue for more details: ' \
                            'https://github.com/hanami/model/issues/250'.freeze

        # @since 0.4.0
        # @api private
        def create
          set_environment_variables

          new_connection(global: true).run %(CREATE DATABASE #{quotate_string(database)};)
        rescue Sequel::DatabaseError => e
          message = if e.message.match(/database exists/) ||
                       e.message.match(/already exists/)
                      DB_CREATION_ERROR
                    else
                      e.message
                    end

          raise MigrationError.new(message)
        end

        # @since 0.4.0
        # @api private
        def drop
          set_environment_variables

          new_connection(global: true).run %(DROP DATABASE #{quotate_string(database)};)
        rescue Sequel::DatabaseError => e
          message = if e.message.match(/doesn\'t exist/) ||
                       e.message.match(/does not exist/)

                      "Cannot find database: #{database}"
                    else
                      e.message
                    end

          raise MigrationError.new(message)
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
          execute "pg_dump -s -x -O -T #{migrations_table} -f #{escape(schema)} #{database}"
        end

        # @since 0.4.0
        # @api private
        def load_structure
          return unless schema.exist?
          file = File.open(escape(schema), 'r')
          new_connection(global: false).run file.read
          file.close
        end

        # @since 0.4.0
        # @api private
        def dump_migrations_data
          error = ->(err) { raise MigrationError.new(err) unless err =~ /no matching tables/i }
          execute "pg_dump -t #{migrations_table} #{database} >> #{escape(schema)}", error: error
        end

        # @since 0.5.1
        # @api private
        def call_db_command(command)
          require 'open3'

          begin
            Open3.popen3(command, database) do |_stdin, _stdout, stderr, wait_thr|
              unless wait_thr.value.success? # wait_thr.value is the exit status
                raise MigrationError.new(modified_message(stderr.read))
              end
            end
          rescue SystemCallError => e
            raise MigrationError.new(modified_message(e.message))
          end
        end

        # @since 1.1.0
        # @api private
        def modified_message(original_message)
          case original_message
          when /already exists/
            DB_CREATION_ERROR
          when /does not exist/
            "Cannot find database: #{database}"
          when /No such file or directory/
            "Could not find executable in your PATH: `#{original_message.split.last}`"
          else
            original_message
          end
        end

        def quotate_string(string)
          if string.start_with?('"', "'")
            string
          else
            "\"#{string}\""
          end
        end
      end
    end
  end
end
