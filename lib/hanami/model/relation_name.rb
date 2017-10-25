require_relative 'entity_name'
require 'hanami/utils/string'

module Hanami
  module Model
    # Conventional name for relations.
    #
    # Given a repository named <tt>SourceFileRepository</tt>, the associated
    # relation will be <tt>:source_files</tt>.
    #
    # @since 0.7.0
    # @api private
    class RelationName < EntityName
      # @param name [Class,String] the class or its name
      # @return [String] the relation name
      #
      # @since 0.7.0
      # @api private
      def self.new(name)
        Utils::String.transform(super, :underscore, :pluralize)
      end
    end
  end
end
