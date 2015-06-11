module Lotus
  module Model
    module Migrator
      class PostgresAdapter < Adapter
        def create
          new_connection.run %(CREATE DATABASE "#{ database }"#{ create_options })
        end

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

        def dump
          dump_structure
          dump_migrations_data
        end

        private
        def create_options
          result  = ""
          result += %( OWNER "#{ options.fetch(:user) }") if options.fetch(:user, nil)
          result
        end

        def dump_structure
          system "pg_dump -i -s -x -O -T #{ migrations_table } -f #{ schema } #{ database }"
        end

        def dump_migrations_data
          system "pg_dump -t #{ migrations_table } #{ database } >> #{ schema }"
        end
      end
    end
  end
end
