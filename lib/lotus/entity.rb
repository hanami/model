require 'lotus/utils/kernel'
require 'lotus/utils/attributes'

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
  #     attributes :name, :age
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
      base.class_eval do
        extend ClassMethods
        attributes :id
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
      # @param attrs [Array<Symbol>] a set of arbitrary attribute names
      #
      # @since 0.2.0
      #
      # @see Lotus::Repository
      # @see Lotus::Model::Mapper
      #
      # @example
      #   require 'lotus/model'
      #
      #   class User
      #     include Lotus::Entity
      #     attributes :name, :age
      #   end
      #   User.attributes => #<Set: {:id, :name, :age}>
      #
      # @example Given params is array of attributes
      #   require 'lotus/model'
      #
      #   class User
      #     include Lotus::Entity
      #     attributes [:name, :age]
      #   end
      #   User.attributes => #<Set: {:id, :name, :age}>
      #
      # @example Extend entity
      #   require 'lotus/model'
      #
      #   class User
      #     include Lotus::Entity
      #     attributes :name
      #   end
      #
      #   class DeletedUser < User
      #     include Lotus::Entity
      #     attributes :deleted_at
      #   end
      #
      #   User.attributes => #<Set: {:id, :name}>
      #   DeletedUser.attributes => #<Set: {:id, :name, :deleted_at}>
      #
      def attributes(*attrs)
        if attrs.any?
          attrs = Lotus::Utils::Kernel.Array(attrs)
          self.attributes.merge attrs

          attrs.each do |attr|
            define_attr_accessor(attr) if defined_attribute?(attr)
          end
        else
          @attributes ||= Set.new
        end
      end

      # Define setter/getter methods for attributes.
      #
      # @param attr [Symbol] an attribute name
      #
      # @since 0.3.1
      # @api private
      def define_attr_accessor(attr)
        attr_accessor(attr)
      end

      # Check if attr_reader define the given attribute
      #
      # @since 0.3.1
      # @api private
      def defined_attribute?(name)
        name == :id ||
          !instance_methods.include?(name)
      end

      protected

      # @see Class#inherited
      def inherited(subclass)
        subclass.attributes(*attributes)
        super
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
        setter = "#{ k }="
        public_send(setter, v) if respond_to?(setter)
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
    #     attributes :name
    #   end
    #
    #   user = User.new(id: 23, name: 'Luca')
    #   user.to_h # => { :id => 23, :name => "Luca" }
    def to_h
      Hash[attribute_names.map { |a| [a, read_attribute(a)] }]
    end

    # Return the set of attribute names
    #
    # @since 0.5.1
    #
    # @example
    #   require 'lotus/model'
    #   class User
    #     include Lotus::Entity
    #     attributes :name
    #   end
    #
    #   user = User.new(id: 23, name: 'Luca')
    #   user.attribute_names # #<Set: {:id, :name}>
    def attribute_names
      self.class.attributes
    end

    # Return the contents of the entity as a nicely formatted string.
    #
    # Display all attributes of the entity for inspection (even if they are nil)
    #
    # @since 0.5.1
    #
    # @example
    #   require 'lotus/model'
    #   class User
    #     include Lotus::Entity
    #     attributes :name, :email
    #   end
    #
    #   user = User.new(id: 23, name: 'Luca')
    #   user.inspect # #<User:0x007fa7eefe0b58 @id=nil @name="Luca" @email=nil>
    def inspect
      attr_list = attribute_names.inject([]) do |res, name|
        res << "@#{name}=#{read_attribute(name).inspect}"
      end.join(' ')

      "#<#{self.class.name}:0x00#{(__id__ << 1).to_s(16)} #{attr_list}>"
    end

    alias_method :to_s, :inspect

    # Set attributes for entity
    #
    # @since 0.2.0
    #
    # @example
    #   require 'lotus/model'
    #   class User
    #     include Lotus::Entity
    #     attributes :name
    #   end
    #
    #   user = User.new(name: 'Lucca')
    #   user.update(name: 'Luca')
    #   user.name # => 'Luca'
    def update(attributes={})
      attributes.each do |attribute, value|
        public_send("#{attribute}=", value)
      end
    end

    private

    # Return the value by attribute name
    #
    # @since 0.5.1
    # @api private
    def read_attribute(attr_name)
      public_send(attr_name)
    end
  end
end
