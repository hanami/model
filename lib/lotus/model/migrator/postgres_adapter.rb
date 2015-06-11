module Lotus
  module Model
    module Migrator
      # PostgreSQL adapter
      #
      # @since x.x.x
      # @api private
      class PostgresAdapter < Adapter
        # @since x.x.x
        # @api private
        HOST     = 'PGHOST'.freeze

        # @since x.x.x
        # @api private
        PORT     = 'PGPORT'.freeze

        # @since x.x.x
        # @api private
        USER     = 'PGUSER'.freeze

        # @since x.x.x
        # @api private
        PASSWORD = 'PGPASSWORD'.freeze

        # @since x.x.x
        # @api private
        def create
          new_connection.run %(CREATE DATABASE "#{ database }"#{ create_options })
        end

        # @since x.x.x
        # @api private
        def drop
          new_connection.run %(DROP DATABASE "#{ database }")
        rescue Sequel::DatabaseError => e
          message = if e.message.match(/does not exist/)
            "Cannot find database: #{ database }"
          else
            e.message
          end

          raise MigrationError.new(message)
        end

        # @since x.x.x
        # @api private
        def dump
          set_environment_variables
          dump_structure
          dump_migrations_data
        end

        # @since x.x.x
        # @api private
        def load
          set_environment_variables
          load_structure
        end

        private

        # @since x.x.x
        # @api private
        def create_options
          result  = ""
          result += %( OWNER "#{ username }") unless username.nil?
          result
        end

        # @since x.x.x
        # @api private
        def set_environment_variables
          ENV[HOST]     = host      unless host.nil?
          ENV[PORT]     = port.to_s unless port.nil?
          ENV[PASSWORD] = password  unless password.nil?
          ENV[USER]     = username  unless username.nil?
        end

        # @since x.x.x
        # @api private
        def dump_structure
          system "pg_dump -i -s -x -O -T #{ migrations_table } -f #{ escape(schema) } #{ database }"
        end

        # @since x.x.x
        # @api private
        def load_structure
          system "psql -X -q -f #{ escape(schema) } #{ database }" if schema.exist?
        end

        # @since x.x.x
        # @api private
        def dump_migrations_data
          system "pg_dump -t #{ migrations_table } #{ database } >> #{ escape(schema) }"
        end
      end
    end
  end
end
