require 'hanami/model/mapping/collection'
require 'hanami/model/mapping/collection_coercer'
require 'hanami/model/mapping/coercers'

module Hanami
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
      class UnmappedCollectionError < Hanami::Model::Error
        def initialize(name)
          super("Cannot find collection: #{ name }")
        end
      end

      # Invalid entity error.
      #
      # It gets raised when the application tries to access to a existing
      # entity.
      #
      # @since 0.2.0
      class EntityNotFound < Hanami::Model::Error
        def initialize(name)
          super("Cannot find class for entity: #{ name }")
        end
      end

      # Invalid repository error.
      #
      # It gets raised when the application tries to access to a existing
      # repository.
      #
      # @since 0.2.0
      class RepositoryNotFound < Hanami::Model::Error
        def initialize(name)
          super("Cannot find class for repository: #{ name }")
        end
      end
    end
  end
end
