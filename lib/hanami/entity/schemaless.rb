# frozen_string_literal: true

require "dry/struct"
require "hanami/utils/hash"

module Hanami
  class Entity < Dry::Struct
    # Schemaless entity
    #
    # @since 2.0.0
    class Schemaless < Dry::Struct
      def self.load(attributes = {})
        return attributes if attributes.is_a?(self)

        super(Utils::Hash.deep_symbolize(attributes.to_hash)).freeze
      end

      class << self
        alias new load
        alias call load
        alias call_unsafe load
      end

      def id
        attributes.fetch(:id, nil)
      end

      def method_missing(method_name, *args)
        if args.empty? && attributes.key?(method_name)
          attributes[method_name]
        else
          super
        end
      end

      def respond_to_missing?(method_name, include_all)
        super || attributes.key?(method_name)
      end

      def freeze
        attributes.freeze
        super
      end

      def to_h
        Utils::Hash.deep_dup(attributes)
      end

      alias to_hash to_h

      def inspect
        "#<#{self.class.name} #{attributes.map { |k, v| "#{k}=#{v.inspect}" }.join(' ')}>"
      end
      alias to_s inspect
    end
  end
end
