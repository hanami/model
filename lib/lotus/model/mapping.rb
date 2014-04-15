require 'lotus/model/mapping/collection'

module Lotus
  module Model
    # Mapping internal utilities
    #
    # @since 0.1.0
    module Mapping
      # Unmapped collection error.
      #
      # It gets raised when the application tries to access to a non-mapped
      # collection.
      #
      # @since 0.1.0
      class UnmappedCollectionError < ::StandardError
        def initialize(name)
          super("Cannot find collection: #{ name }")
        end
      end
    end
  end
end
