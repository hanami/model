require 'transproc/all'

module Hanami
  module Model
    # Mapping
    #
    # @since 0.1.0
    # @api private
    class Mapping
      extend Transproc::Registry

      import Transproc::HashTransformations

      # @since 0.1.0
      # @api private
      def initialize(&blk)
        @attributes   = {}
        @r_attributes = {}
        instance_eval(&blk)
        @processor = @attributes.empty? ? ::Hash : t(:rename_keys, @attributes)
      end

      # @api private
      def t(name, *args)
        self.class[name, *args]
      end

      # @api private
      def model(entity)
      end

      # @api private
      def register_as(name)
      end

      # @api private
      def attribute(name, options)
        from = options.fetch(:from, name)

        @attributes[name]   = from
        @r_attributes[from] = name
      end

      # @api private
      def process(input)
        @processor[input]
      end

      # @api private
      def reverse?
        @r_attributes.any?
      end

      # @api private
      def translate(attribute)
        @r_attributes.fetch(attribute)
      end
    end
  end
end
