module Hanami
  module Model
    # Plugins to extend read/write operations from/to the database
    #
    # @since 0.7.0
    # @api private
    module Plugins
      # Wrapping input
      #
      # @since 0.7.0
      # @api private
      class WrappingInput
        # @since 0.7.0
        # @api private
        def initialize(_relation, input)
          @input = input || Hash
        end
      end

      require 'hanami/model/plugins/mapping'
      require 'hanami/model/plugins/schema'
      require 'hanami/model/plugins/timestamps'
    end
  end
end
