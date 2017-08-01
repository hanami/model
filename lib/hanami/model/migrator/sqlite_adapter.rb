require 'pathname'
require 'hanami/utils'
require 'English'

module Hanami
  module Model
    class Migrator
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
        def initialize(configuration)
          super
          extend Memory if memory?
        end

        # @since 0.4.0
        # @api private
        def create
          path.dirname.mkpath
          FileUtils.touch(path)
        rescue Errno::EACCES, Errno::EPERM
          raise MigrationError.new("Permission denied: #{path.sub(/\A\/\//, '')}")
        end

        # @since 0.4.0
        # @api private
        def drop
          path.delete
        rescue Errno::ENOENT
          raise MigrationError.new("Cannot find database: #{path.sub(/\A\/\//, '')}")
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
            @connection.uri.sub(/\A(jdbc:sqlite:\/\/|sqlite:\/\/)/, '')
          )
        end

        # @since 0.4.0
        # @api private
        def root
          Hanami::Model.configuration.root
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
          execute "sqlite3 #{escape(path)} .schema > #{escape(schema)}"
        end

        # @since 0.4.0
        # @api private
        def load_structure
          execute "sqlite3 #{escape(path)} < #{escape(schema)}" if schema.exist?
        end

        # @since 0.4.0
        # @api private
        #
        # rubocop:disable Metrics/AbcSize
        # rubocop:disable Metrics/MethodLength
        def dump_migrations_data
          execute "sqlite3 #{escape(path)} .dump" do |stdout|
            begin
              contents = stdout.read.split($INPUT_RECORD_SEPARATOR)
              contents = contents.grep(/^INSERT INTO "#{migrations_table}"/)

              ::File.open(schema, ::File::CREAT | ::File::BINARY | ::File::WRONLY | ::File::APPEND) do |file|
                file.write(contents.join($INPUT_RECORD_SEPARATOR))
              end
            rescue => exception
              raise MigrationError.new(exception.message)
            end
          end
        end
        # rubocop:enable Metrics/MethodLength
        # rubocop:enable Metrics/AbcSize
      end
    end
  end
end
