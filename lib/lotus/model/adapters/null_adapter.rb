module Lotus
  module Model
    module Adapters
      # @since 0.2.0
      class NoAdapterError < ::StandardError
        def initialize(method_name)
          super("Cannot invoke `#{ method_name }' without selecting an adapter. Please check your framework configuration.")
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
