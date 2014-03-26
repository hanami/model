require 'lotus/model/version'
require 'lotus/model/entity'
require 'lotus/model/repository'

module Lotus
  module Model
    # Error for not found entity
    #
    # @since 0.1.0
    #
    # @see Lotus::Model::Repository.find
    class EntityNotFound < ::StandardError
    end

    # Error for non persisted entity
    # It's raised when we try to update or delete a non persisted entity.
    #
    # @since 0.1.0
    #
    # @see Lotus::Model::Repository.update
    class NonPersistedEntityError < ::StandardError
    end
  end
end
