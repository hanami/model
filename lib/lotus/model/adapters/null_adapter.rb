class NoAdapterError < StandardError ;end
module Lotus
  module Model
    module Adapters
      class NullAdapter
        def method_missing(*)
          raise NoAdapterError, "Adapter must be selected to persist data"
        end
      end
    end
  end
end