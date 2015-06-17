require 'pathname'

module Lotus
  module Model
    module Migrator
      # SQLite3 Migrator
      #
      # @since 0.4.0
      # @api private
      class SQLiteAdapter < Adapter
        # No-op for in-memory databases
        #
        # @since 0.4.0
        # @api private
        module Memory
          # @since 0.4.0
          # @api private
          def create
          end

          # @since 0.4.0
          # @api private
          def drop
          end
        end

        # Initialize adapter
        #
        # @since 0.4.0
        # @api private
        def initialize(connection)
          super
          extend Memory if memory?
        end

        # @since 0.4.0
        # @api private
        def create
          path.dirname.mkpath
          FileUtils.touch(path)
        rescue Errno::EACCES
          raise MigrationError.new("Permission denied: #{ path.sub(/\A\/\//, '') }")
        end

        # @since 0.4.0
        # @api private
        def drop
          path.delete
        rescue Errno::ENOENT
          raise MigrationError.new("Cannot find database: #{ path.sub(/\A\/\//, '') }")
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
        def path
          root.join(
            @connection.uri.sub(/#{ @connection.adapter_scheme }\:\/\//, '')
          )
        end

        # @since 0.4.0
        # @api private
        def root
          Lotus::Model.configuration.root
        end

        # @since 0.4.0
        # @api private
        def memory?
          uri = path.to_s
          uri.match(/sqlite\:\/\z/) ||
            uri.match(/\:memory\:/)
        end

        # @since 0.4.0
        # @api private
        def dump_structure
          system "sqlite3 #{ escape(path) } .schema > #{ escape(schema) }"
        end

        # @since 0.4.0
        # @api private
        def load_structure
          system "sqlite3 #{ escape(path) } < #{ escape(schema) }" if schema.exist?
        end

        # @since 0.4.0
        # @api private
        def dump_migrations_data
          system %(sqlite3 #{ escape(path) } .dump | grep '^INSERT INTO "#{ migrations_table }"' >> #{ escape(schema) })
        end
      end
    end
  end
end
