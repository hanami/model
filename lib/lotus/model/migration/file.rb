module Lotus
  module Model
    class Migration
      # This class represents the migration file object
      #
      # @since x.x.x
      # @api private
      class File < ::File
        # The timestamp migration file naming pattern
        # Migration file follows format:
        #
        # <yyyymmddhhmmss>_<title>.rb
        #
        # @since x.x.x
        MIGRATION_FILE_PATTERN = /\A(\d{14})_.+\.rb\z/i.freeze

        # Returns the version of the migration file
        #
        # @since x.x.x
        attr_reader :version

        def initialize(*)
          super
          @version = _get_version_from_filename(self.path)
        end

        # Check if file is migration file
        #
        # @param [String] filename
        # @example Filename that comply with timestamp migration format
        #   filename = '20150122124515_create_posts.rb'
        #   Lotus::Model::Migration::File.migration_file?(filename)
        #   # => true
        #
        # @since x.x.x
        def self.migration_file?(filename)
          !!MIGRATION_FILE_PATTERN.match(filename)
        end

        private

        # Extract version from filename
        #
        # @api private
        # @since x.x.x
        def _get_version_from_filename(filename)
          MIGRATION_FILE_PATTERN.match(File.basename(filename))[1].to_i
        end
      end
    end
  end
end
