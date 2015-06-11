module Lotus
  module Model
    module Migrator
      class MySQLAdapter < Adapter
        def create
          new_connection.run %(CREATE DATABASE #{ database };)
        end

        def drop
          new_connection.run %(DROP DATABASE #{ database };)
        rescue Sequel::DatabaseError => e
          message = if e.message.match(/doesn\'t exist/)
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

        def dump_structure
          system "mysqldump --user=#{ username } --password=#{ password } --no-data --skip-comments --ignore-table=#{ database }.#{ migrations_table } #{ database } > #{ schema }"
        end

        def dump_migrations_data
          system "mysqldump --user=#{ username } --password=#{ password } --skip-comments #{ database } #{ migrations_table } >> #{ schema }"
        end
      end
    end
  end
end
