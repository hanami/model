require 'hanami/utils/class'

module Hanami
  module Model
    module Mapping
      # Mapping attribute
      #
      # @api private
      # @since 0.5.0
      class Attribute
        # @api private
        # @since 0.5.0
        COERCERS_NAMESPACE = "Hanami::Model::Mapping::Coercers".freeze

        # Initialize a new attribute
        #
        # @param name [#to_sym] attribute name
        # @param coercer [.load, .dump] a coercer
        # @param options [Hash] a set of options
        #
        # @option options [#to_sym] :as Resolve mismatch between database column
        #   name and entity attribute name
        #
        # @return [Hanami::Model::Mapping::Attribute]
        #
        # @api private
        # @since 0.5.0
        #
        # @see Hanami::Model::Coercer
        # @see Hanami::Model::Mapping::Coercers
        # @see Hanami::Model::Mapping::Collection#attribute
        def initialize(name, coercer, options)
          @name    = name.to_sym
          @coercer = coercer
          @options = options
        end

        # Returns the mapped name
        #
        # @return [Symbol] the mapped name
        #
        # @api private
        # @since 0.5.0
        #
        # @see Hanami::Model::Mapping::Collection#attribute
        def mapped
          (@options.fetch(:as) { name }).to_sym
        end

        # @api private
        # @since 0.5.0
        def load_coercer
          "#{ coercer }.load"
        end

        # @api private
        # @since 0.5.0
        def dump_coercer
          "#{ coercer }.dump"
        end

        # @api private
        # @since 0.5.0
        def ==(other)
          self.class     == other.class   &&
            self.name    == other.name    &&
            self.mapped  == other.mapped  &&
            self.coercer == other.coercer
        end

        protected

        # @api private
        # @since 0.5.0
        attr_reader :name

        # @api private
        # @since 0.5.0
        def coercer
          Utils::Class.load_from_pattern!("(#{ COERCERS_NAMESPACE }::#{ @coercer }|#{ @coercer })")
        end
      end
    end
  end
end
