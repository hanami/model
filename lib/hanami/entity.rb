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
  #     attributes :name, :age
  #   end
  #
  # When a class includes `Hanami::Entity` it receives the following interface:
  #
  #   * #id
  #   * #id=
  #   * #initialize(attributes = {})
  #
  # `Hanami::Entity` also provides the `.attributes=` for defining attribute accessors for the given names.
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
    def initialize(attributes = nil)
      @attributes = (attributes || {}).dup.freeze
      freeze
    end

    def method_missing(m)
      attributes.fetch(m, nil)
    end

    def ==(other)
      self.class == other.class &&
        id == other.id
    end

    private

    attr_reader :attributes
  end
end
