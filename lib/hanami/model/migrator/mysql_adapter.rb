module Hanami
  module Model
    class Migrator
      # MySQL adapter
      #
      # @since 0.4.0
      # @api private
      class MySQLAdapter < Adapter
        # @since 0.7.0
        # @api private
        PASSWORD = 'MYSQL_PWD'.freeze

        # @since 1.0.0
        # @api private
        DB_CREATION_ERROR = 'Database creation failed. If the database exists, ' \
                            'then its console may be open. See this issue for more details: ' \
                            'https://github.com/hanami/model/issues/250'.freeze

        # @since 0.4.0
        # @api private
        def create
          new_connection(global: true).run %(CREATE DATABASE `#{database}`;)
        rescue Sequel::DatabaseError => e
          message = if e.message.match(/database exists/) # rubocop:disable Performance/RedundantMatch
                      DB_CREATION_ERROR
                    else
                      e.message
                    end

          raise MigrationError.new(message)
        end

        # @since 0.4.0
        # @api private
        def drop
          new_connection(global: true).run %(DROP DATABASE `#{database}`;)
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
          dump_structure
          dump_migrations_data
        end

        # @since 0.4.0
        # @api private
        def load
          load_structure
        end

        private

        # @since 0.7.0
        # @api private
        def password
          connection.password
        end

        # @since 0.4.0
        # @api private
        def dump_structure
          execute "mysqldump --host=#{host} --port=#{port} --user=#{username} --no-data --skip-comments --ignore-table=#{database}.#{migrations_table} #{database} > #{schema}", env: { PASSWORD => password }
        end

        # @since 0.4.0
        # @api private
        def load_structure
          execute("mysql --host=#{host} --port=#{port} --user=#{username} #{database} < #{escape(schema)}", env: { PASSWORD => password }) if schema.exist?
        end

        # @since 0.4.0
        # @api private
        def dump_migrations_data
          execute "mysqldump --host=#{host} --port=#{port} --user=#{username} --skip-comments #{database} #{migrations_table} >> #{schema}", env: { PASSWORD => password }
        end
      end
    end
  end
end
