require 'lotus/model/version'
require 'lotus/model/entity'

module Lotus
  module Model
    # Error for not found record
    #
    # @since 0.1.0
    #
    # @see Lotus::Model::Repository.find
    class RecordNotFound < ::StandardError
    end
  end
end
