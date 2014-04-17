require 'lotus/utils/kernel'

module Lotus
  # An object that is not defined by its attributes, by but it's identity.
  # See Domain Driven Design by Eric Evans.
  #
  # An entity is the core of an application, where the part of the domain
  # logic is implemented. It's small, cohesive object that express coherent
  # and meagniful behaviors.
  #
  # It implements one and only one responsibility that is pertinent to the
  # domain of the application, without caring about details such as persistence
  # or validations.
  #
  # This simplicity of design allows developers to focus on behaviors, or
  # message passing if you will, which is the core of Object Oriented Programming.
  #
  #
  #
  # Lotus::Model ships Entity only for ease of usage for developers, but the
  # can work with any Ruby object that implement the following interface:
  #
  #   * #id
  #   * #id=
  #   * #initialize(attributes = {})
  #
  # For instance an entity can be created by using a `Struct`:
  #
  # @example
  #   require 'lotus/model'
  #
  #   Person = Struct.new(:id, :name)
  #     def initialize(attributes = {})
  #       @id, @name = attributes.values_at(:id, :name)
  #     end
  #   end
  #
  #   person = Person.new(name: 'Luca')
  #
  #   class PersonRepository
  #     include Lotus::Repository
  #   end
  #
  #   PersonRepository.create(person)
  #
  # However, we suggest to implement this interface by including `Lotus::Entity`,
  # in case that future versions of the framework will expand it.
  #
  # @since 0.1.0
  #
  # @see Lotus::Repository
  module Entity
    # Inject the public API into the hosting class.
    #
    # @since 0.1.0
    #
    # @example With Object
    #   require 'lotus/model'
    #
    #   class User
    #     include Lotus::Entity
    #   end
    #
    # @example With Struct
    #   require 'lotus/model'
    #
    #   User = Struct.new(:id, :name) do
    #     include Lotus::Entity
    #   end
    def self.included(base)
      base.class_eval do
        extend ClassMethods
      end
    end

    module ClassMethods
      # (Re)defines getters, setters and initialization for the given attributes.
      #
      # These attributes can match the database columns, but this isn't a
      # requirement. The mapper used by the relative repository will translate
      # these names automatically.
      #
      # An entity can work with attributes not configured in the mapper, but
      # of course they will be ignored when the entity will be persisted.
      #
      # Please notice that the required `id` attribute is automatically defined
      # and can be omitted in the arguments.
      #
      # @param attributes [Array<Symbol>] a set of arbitrary attribute names
      #
      # @since 0.1.0
      #
      # @see Lotus::Repository
      # @see Lotus::Model::Mapper
      #
      # @example
      #   require 'lotus/model'
      #
      #   class User
      #     include Lotus::Entity
      #     self.attributes = :name
      #   end
      def attributes=(*attributes)
        @attributes = Lotus::Utils::Kernel.Array(attributes.unshift(:id))

        class_eval %{
          def initialize(attributes = {})
        #{ @attributes.map {|a| "@#{a}" }.join(', ') }, = *attributes.values_at(#{ @attributes.map {|a| ":#{a}"}.join(', ') })
          end
        }

        @attributes.each do |attr|
          class_eval do
            attr_accessor attr
          end
        end
      end

      def attributes
        @attributes
      end
    end

    # Defines a generic, inefficient initializer, in case that the attributes
    # weren't explicitly defined with `.attributes=`.
    #
    # @param attributes [Hash] a set of attribute names and values
    #
    # @raise NoMethodError in case the given attributes are trying to set unknown
    #   or private methods.
    #
    # @since 0.1.0
    #
    # @see .attributes
    def initialize(attributes = {})
      attributes.each do |k, v|
        public_send("#{ k }=", v)
      end
    end

    # Overrides the equality Ruby operator
    #
    # Two entities are considered equal if they are instances of the same class
    # and if they have the same #id.
    #
    # @since 0.1.0
    def ==(other)
      self.class == other.class &&
         self.id == other.id
    end
  end
end

