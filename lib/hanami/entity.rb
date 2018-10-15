require 'hanami/model/types'

module Hanami
  # An object that is defined by its identity.
  # See "Domain Driven Design" by Eric Evans.
  #
  # An entity is the core of an application, where the part of the domain
  # logic is implemented. It's a small, cohesive object that expresses coherent
  # and meaningful behaviors.
  #
  # It deals with one and only one responsibility that is pertinent to the
  # domain of the application, without caring about details such as persistence
  # or validations.
  #
  # This simplicity of design allows developers to focus on behaviors, or
  # message passing if you will, which is the quintessence of Object Oriented
  # Programming.
  #
  # @example With Hanami::Entity
  #   require 'hanami/model'
  #
  #   class Person < Hanami::Entity
  #   end
  #
  # If we expand the code above in **pure Ruby**, it would be:
  #
  # @example Pure Ruby
  #   class Person
  #     attr_accessor :id, :name, :age
  #
  #     def initialize(attributes = {})
  #       @id, @name, @age = attributes.values_at(:id, :name, :age)
  #     end
  #   end
  #
  # **Hanami::Model** ships `Hanami::Entity` for developers' convenience.
  #
  # **Hanami::Model** depends on a narrow and well-defined interface for an
  # Entity - `#id`, `#id=`, `#initialize(attributes={})`.If your object
  # implements that interface then that object can be used as an Entity in the
  # **Hanami::Model** framework.
  #
  # However, we suggest to implement this interface by including
  # `Hanami::Entity`, in case that future versions of the framework will expand
  # it.
  #
  # See Dependency Inversion Principle for more on interfaces.
  #
  # @since 0.1.0
  #
  # @see Hanami::Repository
  class Entity
    require 'hanami/entity/schema'

    # Syntactic shortcut to reference types in custom schema DSL
    #
    # @since 0.7.0
    module Types
      include Hanami::Model::Types
    end

    # Class level interface
    #
    # @since 0.7.0
    # @api private
    module ClassMethods
      # Define manual entity schema
      #
      # With a SQL database this setup happens automatically and you SHOULD NOT
      # use this DSL. You should use only when you want to customize the automatic
      # setup.
      #
      # If you're working with an entity that isn't "backed" by a SQL table or
      # with a schema-less database, you may want to manually setup a set of
      # attributes via this DSL. If you don't do any setup, the entity accepts all
      # the given attributes.
      #
      # @param type [Symbol] the type of schema to build
      # @param blk [Proc] the block that defines the attributes
      #
      # @since 0.7.0
      #
      # @see Hanami::Entity
      def attributes(type = nil, &blk)
        self.schema = Schema.new(type, &blk)
        @attributes = true
      end

      # Assign a schema
      #
      # @param value [Hanami::Entity::Schema] the schema
      #
      # @since 0.7.0
      # @api private
      def schema=(value)
        return if defined?(@attributes)

        @schema = value
      end

      # @since 0.7.0
      # @api private
      attr_reader :schema
    end

    # @since 0.7.0
    # @api private
    def self.inherited(klass)
      klass.class_eval do
        @schema = Schema.new
        extend  ClassMethods
      end
    end

    # Instantiate a new entity
    #
    # @param attributes [Hash,#to_h,NilClass] data to initialize the entity
    #
    # @return [Hanami::Entity] the new entity instance
    #
    # @raise [TypeError] if the given attributes are invalid
    #
    # @since 0.1.0
    def initialize(attributes = nil)
      @attributes = self.class.schema[attributes]
      freeze
    end

    # Entity ID
    #
    # @return [Object,NilClass] the ID, if present
    #
    # @since 0.7.0
    def id
      attributes.fetch(:id, nil)
    end

    # Handle dynamic accessors
    #
    # If internal attributes set has the requested key, it returns the linked
    # value, otherwise it raises a <tt>NoMethodError</tt>
    #
    # @since 0.7.0
    def method_missing(method_name, *)
      attribute?(method_name) or super
      attributes.fetch(method_name, nil)
    end

    # Implement generic equality for entities
    #
    # Two entities are equal if they are instances of the same class and they
    # have the same id.
    #
    # @param other [Object] the object of comparison
    #
    # @return [FalseClass,TrueClass] the result of the check
    #
    # @since 0.1.0
    def ==(other)
      self.class == other.class &&
        id == other.id
    end

    # Implement predictable hashing for hash equality
    #
    # @return [Integer] the object hash
    #
    # @since 0.7.0
    def hash
      [self.class, id].hash
    end

    # Freeze the entity
    #
    # @since 0.7.0
    def freeze
      attributes.freeze
      super
    end

    # Serialize entity to a Hash
    #
    # @return [Hash] the result of serialization
    #
    # @since 0.1.0
    def to_h
      Utils::Hash.deep_dup(attributes)
    end

    # @since 0.7.0
    alias to_hash to_h

    protected

    # Check if the attribute is allowed to be read
    #
    # @since 0.7.0
    # @api private
    def attribute?(name)
      self.class.schema.attribute?(name)
    end

    private

    # @since 0.1.0
    # @api private
    attr_reader :attributes

    # @since 0.7.0
    # @api private
    def respond_to_missing?(name, _include_all)
      attribute?(name)
    end
  end
end
