require 'pathname'

module Lotus
  module Model
    module Migrator
      # SQLite3 Migrator
      #
      # @since x.x.x
      # @api private
      class SQLiteAdapter < Adapter
        # Default memory path
        #
        # @since x.x.x
        # @api private
        MEMORY_PATH = '/'.freeze

        # No-op for in-memory databases
        #
        # @since x.x.x
        # @api private
        module Memory
          # @since x.x.x
          # @api private
          def create
          end

          # @since x.x.x
          # @api private
          def drop
          end
        end

        # Initialize adapter
        #
        # @since x.x.x
        # @api private
        def initialize(connection)
          super
          extend Memory if memory?
        end

        # @since x.x.x
        # @api private
        def create
          path.dirname.mkpath
          FileUtils.touch(path)
        rescue Errno::EACCES
          raise MigrationError.new("Permission denied: #{ path.sub(/\A\/\//, '') }")
        end

        # @since x.x.x
        # @api private
        def drop
          path.delete
        rescue Errno::ENOENT
          raise MigrationError.new("Cannot find database: #{ path.sub(/\A\/\//, '') }")
        end

        # @since x.x.x
        # @api private
        def dump
          dump_structure
          dump_migrations_data
        end

        private

        # @since x.x.x
        # @api private
        def path
          Pathname.new(@connection.uri.sub("#{ @connection.adapter_scheme }:", ''))
        end

        # @since x.x.x
        # @api private
        def memory?
          uri = path.to_s
          uri == MEMORY_PATH ||
            uri.match(/\:memory\:/)
        end

        # @since x.x.x
        # @api private
        def dump_structure
          system "sqlite3 #{ path } .schema > #{ schema }"
        end

        # @since x.x.x
        # @api private
        def dump_migrations_data
          system %(sqlite3 #{ path } .dump | grep '^INSERT INTO "#{ migrations_table }"' >> #{ schema })
        end
      end
    end
  end
end
