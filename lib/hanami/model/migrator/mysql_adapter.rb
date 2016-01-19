module Hanami
  module Model
    module Migrator
      # MySQL adapter
      #
      # @since 0.4.0
      # @api private
      class MySQLAdapter < Adapter
        # @since 0.4.0
        # @api private
        def create
          new_connection(global: true).run %(CREATE DATABASE #{ database };)
        rescue Sequel::DatabaseError => e
          message = if e.message.match(/database exists/)
            "Database creation failed. There is 1 other session using the database"
          else
            e.message
          end

          raise MigrationError.new(message)
        end

        # @since 0.4.0
        # @api private
        def drop
          new_connection(global: true).run %(DROP DATABASE #{ database };)
        rescue Sequel::DatabaseError => e
          message = if e.message.match(/doesn\'t exist/)
            "Cannot find database: #{ database }"
          else
            e.message
          end

          raise MigrationError.new(message)
        end

        # @since 0.4.0
        # @api private
        def dump
          dump_structure
          dump_migrations_data
        end

        # @since 0.4.0
        # @api private
        def load
          load_structure
        end

        private

        # @since 0.4.0
        # @api private
        def dump_structure
          system "mysqldump --user=#{ username } --password=#{ password } --no-data --skip-comments --ignore-table=#{ database }.#{ migrations_table } #{ database } > #{ schema }"
        end

        # @since 0.4.0
        # @api private
        def load_structure
          system "mysql --user=#{ username } --password=#{ password } #{ database } < #{ escape(schema) }" if schema.exist?
        end

        # @since 0.4.0
        # @api private
        def dump_migrations_data
          system "mysqldump --user=#{ username } --password=#{ password } --skip-comments #{ database } #{ migrations_table } >> #{ schema }"
        end
      end
    end
  end
end
