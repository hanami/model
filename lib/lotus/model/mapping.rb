require 'lotus/model/mapping/collection'

module Lotus
  module Model
    module Mapping
      class UnmappedCollectionError < ::StandardError
        def initialize(name)
          super("Cannot find collection: #{ name }")
        end
      end
    end
  end
end
