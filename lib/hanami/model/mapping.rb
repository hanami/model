require 'transproc'

module Hanami
  module Model
    # Mapping
    #
    # @since 0.1.0
    class Mapping
      def initialize(&blk)
        @attributes = {}
        instance_eval(&blk)
        @processor = @attributes.empty? ? ::Hash : Transproc(:rename_keys, @attributes)
      end

      def model(entity)
      end

      def register_as(name)
      end

      def attribute(name, options)
        @attributes[name] = options.fetch(:from, name)
      end

      def process(input)
        @processor[input]
      end
    end
  end
end
