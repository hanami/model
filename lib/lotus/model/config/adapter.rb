module Lotus
  module Model
    module Config

      # Adapter configuration
      #
      # @since x.x.x
      # @api private
      class Adapter
        ADAPTER_TYPES = {
          :sql => Lotus::Model::Adapters::SqlAdapter,
          :memory => Lotus::Model::Adapters::MemoryAdapter
        }.freeze

        attr_reader :url, :type

        def initialize(url, type)
          @url = url
          @type = type
        end

      end
    end
  end
end
