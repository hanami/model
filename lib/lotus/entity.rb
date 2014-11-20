require 'lotus/utils/kernel'
require 'lotus/utils/hash'

module Lotus
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
  # @example With Lotus::Entity
  #   require 'lotus/model'
  #
  #   class Person
  #     include Lotus::Entity
  #     self.attributes = :name, :age
  #   end
  #
  # When a class includes `Lotus::Entity` it receives the following interface:
  #
  #   * #id
  #   * #id=
  #   * #initialize(attributes = {})
  #
  # `Lotus::Entity` also provides the `.attributes=` for defining attribute accessors for the given names.
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
  # **Lotus::Model** ships `Lotus::Entity` for developers's convenience.
  #
  # **Lotus::Model** depends on a narrow and well-defined interface for an
  # Entity - `#id`, `#id=`, `#initialize(attributes={})`.If your object
  # implements that interface then that object can be used as an Entity in the
  # **Lotus::Model** framework.
  #
  # However, we suggest to implement this interface by including
  # `Lotus::Entity`, in case that future versions of the framework will expand
  # it.
  #
  # See Dependency Inversion Principle for more on interfaces.
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
      base.extend ClassMethods
      base.send :attr_accessor, :id
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
        include Lotus::Utils::ClassAttribute
        class_attribute :attributes
        self.attributes = Lotus::Utils::Kernel.Array(attributes.unshift(:id))

        class_eval <<-END_EVAL, __FILE__, __LINE__
          #{
            @attributes.map do |a|
              "def #{a}; @attributes[:#{a}]; end;" +
              "def #{a}=(value); @attributes[:#{a}] = value; end;"
            end.join("\n")
          }
        END_EVAL
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
      @attributes = Lotus::Utils::Hash.new

      attributes.each do |key, value|
        if respond_to?("#{key}=")
          public_send("#{key}=", value)
        elsif !defined_attributes
          raise NoMethodError.new("undefined method `#{key}=`")
        end
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

    # Return the hash of attributes
    #
    # @since 0.2.0
    #
    # @example
    #   require 'lotus/model'
    #   class User
    #     include Lotus::Entity
    #     self.attributes = :name
    #   end
    #
    #   user = User.new(id: 23, name: 'Luca')
    #   user.to_h # => {:id => 23, :name => "Luca"}
    def to_h
      @attributes.deep_dup
    end

    private

    # The set of user defined attributes.
    #
    # @since x.x.x
    # @api private
    #
    # @see Lotus::Entity::ClassMethods#attributes
    def defined_attributes
      self.class.attributes
    end
  end
end

