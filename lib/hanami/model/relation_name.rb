require_relative 'entity_name'
require 'hanami/utils/string'

module Hanami
  module Model
    class RelationName < EntityName
      def self.new(name)
        Utils::String.new(super).underscore.pluralize.to_sym
      end
    end
  end
end
