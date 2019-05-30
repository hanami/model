# frozen_string_literal: true

require "dry/struct"
require "hanami/model/types"

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
  class Entity < Dry::Struct
    require "hanami/entity/schema"
    require "hanami/entity/strict"
    require "hanami/entity/schemaless"

    DEFAULT = schema.dup.freeze

    # Syntactic shortcut to reference types in custom schema DSL
    #
    # @since 0.7.0
    module Types
      include Hanami::Model::Types
    end

    def self.inherited(entity)
      super
      schema_policy.call(entity)
    end

    def self.new(attributes = default_attributes, safe = false)
      return if attributes.nil?

      super(Utils::Hash.deep_symbolize(attributes.to_hash), safe).freeze
    rescue Dry::Struct::Error => e
      raise Hanami::Model::Error.new(e.message)
    end

    def self.[](type)
      case type
      when :struct
        Schemaless
      when :strict
        Strict
      else
        raise Hanami::Model::Error.new("Unknown schema type: `#{type.inspect}'")
      end
    end

    def self._schema=(attrs)
      return if schema?

      attrs.each do |name, type|
        attribute(name, type)
      end
    end

    def self.schema?
      defined?(@_schema)
    end

    def self.schema_policy
      lambda do |entity|
        entity.transform_types(&:omittable)
      end
    end

    def self.attribute(name, type = nil, &blk)
      @_schema = true
      super(name, type, &blk)
    end

    # Entity ID
    #
    # @return [Object,NilClass] the ID, if present
    #
    # @since 0.7.0
    def id
      attributes.fetch(:id, nil)
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
      self.class.has_attribute?(name)
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
