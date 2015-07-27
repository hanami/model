module Lotus
  module Model
    module Mapping
      # Mapping attribute
      #
      # @api private
      # @since x.x.x
      class Attribute
        # Initialize a new attribute
        #
        # @param name [#to_sym] attribute name
        # @param klass [Class] a supported Ruby class
        # @param options [Hash] a set of options
        #
        # @option options [#to_sym] :as Resolve mismatch between database column
        #   name and entity attribute name
        #
        # @option options [Class,.call] :coercer A custom coercer that MUST
        #   respond to <tt>.call</tt>
        #
        # @return [Lotus::Model::Mapping::Attribute]
        #
        # @api private
        # @since x.x.x
        #
        # @see Lotus::Model::Mapping::Coercions
        # @see Lotus::Model::Mapping::Collection#attribute
        def initialize(name, klass, options)
          @name    = name.to_sym
          @klass   = klass
          @options = options
        end

        # Returns the mapped name
        #
        # @return [Symbol] the mapped name
        #
        # @api private
        # @since x.x.x
        #
        # @see Lotus::Model::Mapping::Collection#attribute
        def mapped
          (@options.fetch(:as) { name }).to_sym
        end

        # Returns a string representation of the coercer
        #
        # It's a string because we use the returning value with metaprogramming
        #
        # When only the Ruby type is specified with the mapper, the output of
        # this method is:
        #
        #   <tt>Lotus::Model::Mapping::Coercions.String</tt>
        #
        # When a custom coercer is specified, the output is:
        #
        #   <tt>PGArray.</tt>
        #
        # Please note that both the outputs will be called like this by the coercer:
        #
        #   <tt>Lotus::Model::Mapping::Coercions.String(value)</tt>
        #   <tt>PGArray.(value)</tt>
        #
        # For those who are unfamiliar with the latest notation, it's a shortcut
        # for <tt>PGArray.call(value)</tt>.
        #
        # @return [String] string representation of the coercer to be used with
        #   metaprogramming
        #
        # @api private
        # @since x.x.x
        #
        # @see Lotus::Model::Mapping::Coercer
        def coercer
          if c = @options.fetch(:coercer) { nil }
            "#{ c }."
          else
            "Lotus::Model::Mapping::Coercions.#{ @klass }"
          end
        end

        # @api private
        # @since x.x.x
        def ==(other)
          self.class     == other.class   &&
            self.name    == other.name    &&
            self.mapped  == other.mapped  &&
            self.coercer == other.coercer
        end

        protected

        # @api private
        # @since x.x.x
        attr_reader :name
      end
    end
  end
end
