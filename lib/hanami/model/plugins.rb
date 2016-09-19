module Hanami
  module Model
    module Plugins
      class WrappingInput
        def initialize(relation, input)
          @input = input || Hash
        end
      end

      require 'hanami/model/plugins/mapping'
      require 'hanami/model/plugins/schema'
      require 'hanami/model/plugins/timestamps'
    end
  end
end
