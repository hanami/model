require 'hanami/model/types'
require 'hanami/utils/hash'

module Hanami
  class Entity
    # Entity schema is a definition of a set of typed attributes.
    #
    # @since 0.7.0
    # @api private
    #
    # @example SQL Automatic Setup
    #  require 'hanami/model'
    #
    #   class Account < Hanami::Entity
    #   end
    #
    #   account = Account.new(name: "Acme Inc.")
    #   account.name # => "Hanami"
    #
    #   account = Account.new(foo: "bar")
    #   account.foo # => NoMethodError
    #
    # @example Non-SQL Manual Setup
    #   require 'hanami/model'
    #
    #   class Account < Hanami::Entity
    #     attributes do
    #       attribute :id,         Types::Int
    #       attribute :name,       Types::String
    #       attribute :codes,      Types::Array(Types::Int)
    #       attribute :users,      Types::Array(User)
    #       attribute :email,      Types::String.constrained(format: /@/)
    #       attribute :created_at, Types::DateTime
    #     end
    #   end
    #
    #   account = Account.new(name: "Acme Inc.")
    #   account.name # => "Acme Inc."
    #
    #   account = Account.new(foo: "bar")
    #   account.foo # => NoMethodError
    #
    # @example Schemaless Entity
    #   require 'hanami/model'
    #
    #   class Account < Hanami::Entity
    #   end
    #
    #   account = Account.new(name: "Acme Inc.")
    #   account.name # => "Acme Inc."
    #
    #   account = Account.new(foo: "bar")
    #   account.foo # => "bar"
    class Schema
      # Schemaless entities logic
      #
      # @since 0.7.0
      # @api private
      class Schemaless
        # @since 0.7.0
        # @api private
        def initialize
          freeze
        end

        # @param attributes [#to_hash] the attributes hash
        #
        # @return [Hash]
        #
        # @since 0.7.0
        # @api private
        def call(attributes)
          if attributes.nil?
            {}
          else
            Utils::Hash.deep_symbolize(attributes.to_hash.dup)
          end
        end

        # @since 0.7.0
        # @api private
        def attribute?(_name)
          true
        end
      end

      # Schema definition
      #
      # @since 0.7.0
      # @api private
      class Definition
        # Schema DSL
        #
        # @since 0.7.0
        class Dsl
          # @since 1.1.0
          # @api private
          TYPES = %i[schema strict weak permissive strict_with_defaults symbolized].freeze

          # @since 1.1.0
          # @api private
          DEFAULT_TYPE = TYPES.first

          # @since 0.7.0
          # @api private
          def self.build(type, &blk)
            type ||= DEFAULT_TYPE
            raise Hanami::Model::Error.new("Unknown schema type: `#{type.inspect}'") unless TYPES.include?(type)

            attributes = new(&blk).to_h
            [attributes, Hanami::Model::Types::Coercible::Hash.__send__(type, attributes)]
          end

          # @since 0.7.0
          # @api private
          def initialize(&blk)
            @attributes = {}
            instance_eval(&blk)
          end

          # Define an attribute
          #
          # @param name [Symbol] the attribute name
          # @param type [Dry::Types::Definition] the attribute type
          #
          # @since 0.7.0
          #
          # @example
          #   require 'hanami/model'
          #
          #   class Account < Hanami::Entity
          #     attributes do
          #       attribute :id,         Types::Int
          #       attribute :name,       Types::String
          #       attribute :codes,      Types::Array(Types::Int)
          #       attribute :users,      Types::Array(User)
          #       attribute :email,      Types::String.constrained(format: /@/)
          #       attribute :created_at, Types::DateTime
          #     end
          #   end
          #
          #   account = Account.new(name: "Acme Inc.")
          #   account.name # => "Acme Inc."
          #
          #   account = Account.new(foo: "bar")
          #   account.foo # => NoMethodError
          def attribute(name, type)
            @attributes[name] = type
          end

          # @since 0.7.0
          # @api private
          def to_h
            @attributes
          end
        end

        # Instantiate a new DSL instance for an entity
        #
        # @param blk [Proc] the block that defines the attributes
        #
        # @return [Hanami::Entity::Schema::Dsl] the DSL
        #
        # @since 0.7.0
        # @api private
        def initialize(type = nil, &blk)
          raise LocalJumpError unless block_given?

          @attributes, @schema = Dsl.build(type, &blk)
          @attributes = Hash[@attributes.map { |k, _| [k, true] }]
          freeze
        end

        # Process attributes
        #
        # @param attributes [#to_hash] the attributes hash
        #
        # @raise [TypeError] if the process fails
        # @raise [ArgumentError] if data is missing, or unknown keys are given
        #
        # @since 0.7.0
        # @api private
        def call(attributes)
          schema.call(attributes)
        rescue Dry::Types::SchemaError => e
          raise TypeError.new(e.message)
        rescue Dry::Types::MissingKeyError, Dry::Types::UnknownKeysError => e
          raise ArgumentError.new(e.message)
        end

        # Check if the attribute is known
        #
        # @param name [Symbol] the attribute name
        #
        # @return [TrueClass,FalseClass] the result of the check
        #
        # @since 0.7.0
        # @api private
        def attribute?(name)
          attributes.key?(name)
        end

        private

        # @since 0.7.0
        # @api private
        attr_reader :schema

        # @since 0.7.0
        # @api private
        attr_reader :attributes
      end

      # Build a new instance of Schema with the attributes defined by the given block
      #
      # @param blk [Proc] the optional block that defines the attributes
      #
      # @return [Hanami::Entity::Schema] the schema
      #
      # @since 0.7.0
      # @api private
      def initialize(type = nil, &blk)
        @schema = if block_given?
                    Definition.new(type, &blk)
                  else
                    Schemaless.new
                  end
      end

      # Process attributes
      #
      # @param attributes [#to_hash] the attributes hash
      #
      # @raise [TypeError] if the process fails
      #
      # @since 0.7.0
      # @api private
      def call(attributes)
        Utils::Hash.deep_symbolize(
          schema.call(attributes)
        )
      end

      # @since 0.7.0
      # @api private
      alias [] call

      # Check if the attribute is known
      #
      # @param name [Symbol] the attribute name
      #
      # @return [TrueClass,FalseClass] the result of the check
      #
      # @since 0.7.0
      # @api private
      def attribute?(name)
        schema.attribute?(name)
      end

      protected

      # @since 0.7.0
      # @api private
      attr_reader :schema
    end
  end
end
