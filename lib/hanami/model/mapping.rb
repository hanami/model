require 'transproc'

module Hanami
  module Model
    # Mapping
    #
    # @since 0.1.0
    class Mapping
      def initialize(&blk)
        @attributes   = {}
        @r_attributes = {}
        instance_eval(&blk)
        @processor = @attributes.empty? ? ::Hash : Transproc(:rename_keys, @attributes)
      end

      def model(entity)
      end

      def register_as(name)
      end

      def attribute(name, options)
        from = options.fetch(:from, name)

        @attributes[name]   = from
        @r_attributes[from] = name
      end

      def process(input)
        @processor[input]
      end

      def reverse?
        @r_attributes.any?
      end

      def translate(attribute)
        @r_attributes.fetch(attribute)
      end
    end
  end
end
