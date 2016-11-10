module Hanami
  module Model
    class Migrator
      # MySQL adapter
      #
      # @since 0.4.0
      # @api private
      class MySQLAdapter < Adapter
        # @since x.x.x
        # @api private
        PASSWORD = 'MYSQL_PWD'.freeze

        # @since 0.4.0
        # @api private
        def create # rubocop:disable Metrics/MethodLength
          new_connection(global: true).run %(CREATE DATABASE #{database};)
        rescue Sequel::DatabaseError => e
          message = if e.message.match(/database exists/) # rubocop:disable Performance/RedundantMatch
                      "Database creation failed. If the database exists, \
                         then its console may be open. See this issue for more details:\
                         https://github.com/hanami/model/issues/250\
                      "
                    else
                      e.message
                    end

          raise MigrationError.new(message)
        end

        # @since 0.4.0
        # @api private
        def drop
          new_connection(global: true).run %(DROP DATABASE #{database};)
        rescue Sequel::DatabaseError => e
          message = if e.message.match(/doesn\'t exist/) # rubocop:disable Performance/RedundantMatch
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

        # @since x.x.x
        # @api private
        def set_environment_variables
          ENV[PASSWORD] = password unless password.nil?
        end

        # @since x.x.x
        # @api private
        def password
          connection.password
        end

        # @since 0.4.0
        # @api private
        def dump_structure
          system "mysqldump --user=#{username} --no-data --skip-comments --ignore-table=#{database}.#{migrations_table} #{database} > #{schema}"
        end

        # @since 0.4.0
        # @api private
        def load_structure
          system "mysql --user=#{username} #{database} < #{escape(schema)}" if schema.exist?
        end

        # @since 0.4.0
        # @api private
        def dump_migrations_data
          system "mysqldump --user=#{username} --skip-comments #{database} #{migrations_table} >> #{schema}"
        end
      end
    end
  end
end
