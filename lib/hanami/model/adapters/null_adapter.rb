require 'hanami/model/error'

module Hanami
  module Model
    module Adapters
      # @since 0.2.0
      class NoAdapterError < Hanami::Model::Error
        def initialize(method_name)
          super("Cannot invoke `#{ method_name }' on repository. "\
                "Please check if `adapter' and `mapping' are set, "\
                "and that you call `.load!' on the configuration.")
        end
      end

      # @since 0.2.0
      # @api private
      class NullAdapter
        def method_missing(m, *args)
          raise NoAdapterError.new(m)
        end
      end
    end
  end
end
