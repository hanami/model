require 'pathname'

module Lotus
  module Model
    module Migrator
      class SQLiteAdapter < Adapter
        MEMORY_PATH = '/'.freeze

        module Memory
          def create
          end

          def drop
          end
        end

        def initialize(connection)
          super
          extend Memory if memory?
        end

        def create
          path.dirname.mkpath
          FileUtils.touch(path)
        rescue Errno::EACCES
          raise MigrationError.new("Permission denied: #{ path.sub(/\A\/\//, '') }")
        end

        def drop
          path.delete
        rescue Errno::ENOENT
          raise MigrationError.new("Cannot find database: #{ path.sub(/\A\/\//, '') }")
        end

        def dump
          dump_structure
          dump_migrations_data
        end

        private
        def path
          Pathname.new(@connection.uri.sub("#{ @connection.adapter_scheme }:", ''))
        end

        def memory?
          uri = path.to_s
          uri == MEMORY_PATH ||
            uri.match(/\:memory\:/)
        end

        def dump_structure
          system "sqlite3 #{ path } .schema > #{ schema }"
        end

        def dump_migrations_data
          system %(sqlite3 #{ path } .dump | grep '^INSERT INTO "#{ migrations_table }"' >> #{ schema })
        end
      end
    end
  end
end
