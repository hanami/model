require 'hanami/utils/hash'

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
  #   class Person
  #     include Hanami::Entity
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
  # **Hanami::Model** ships `Hanami::Entity` for developers's convenience.
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
  module Entity
    # Instantiate a new entity
    #
    # @param attributes [Hash,#to_h,NilClass] data to initialize the entity
    #
    # @return [Hanami::Entity] the new entity instance
    #
    # @since 0.1.0
    def initialize(attributes = nil)
      @attributes = Utils::Hash.new((attributes || {}).dup).symbolize!
      freeze
    end

    # Entity ID
    #
    # @return [Object,NilClass] the ID, if present
    #
    # @since x.x.x
    def id
      attributes.fetch(:id, nil)
    end

    # Handle dynamic accessors
    #
    # If internal attributes set has the requested key, it returns the linked
    # value, otherwise it raises a <tt>NoMethodError</tt>
    #
    # @since x.x.x
    def method_missing(m)
      attributes.fetch(m) { super }
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
    # @since x.x.x
    def hash
      [self.class, id].hash
    end

    # Serialize entity to a Hash
    #
    # @return [Hash] the result of serialization
    #
    # @since 0.1.0
    def to_h
      attributes.deep_dup.to_h
    end

    # @since x.x.x
    alias to_hash to_h

    private

    # @since 0.1.0
    # @api private
    attr_reader :attributes

    # @since x.x.x
    # @api private
    def respond_to_missing?(name, _include_all)
      attributes.key?(name)
    end
  end
end
