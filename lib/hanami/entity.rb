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
  # However, we suggest to implement this interface by inheriting
  # `Hanami::Entity`, in case that future versions of the framework will expand
  # it.
  #
  # See Dependency Inversion Principle for more on interfaces.
  #
  # @since 0.1.0
  #
  # @see Hanami::Repository
  class Entity < ROM::Struct
    # Note: This is keeping with the previous "Schemaless" interface that we had.
    # def self.load(attributes = {})
    #   return attributes if attributes.is_a?(self)
    #
    #   super(Utils::Hash.deep_symbolize(attributes.to_hash)).freeze
    # end

    # class << self
    #   alias new load
    #   alias call load
    #   alias call_unsafe load
    # end

    def id
      attributes.fetch(:id) { nil }
    end

    def hash
      [self.class, id].hash
    end

    def ==(other)
      self.class.to_s == other.class.to_s && id == other.id
    end

    # def to_h
    #   Utils::Hash.deep_dup(attributes)
    # end
    # alias to_hash to_h

    # def inspect
    #   "#<#{self.class.name} #{attributes.map { |k, v| "#{k}=#{v.inspect}" }.join(' ')}>"
    # end
    # alias to_s inspect

    def method_missing(method_name, *args)
      # return attributes[method_name] if args.empty? && attributes.key?(method_name)

      super
    rescue => exception
      raise Hanami::Model::Error.for(exception)
    end

    # def respond_to_missing?(method_name, include_all)
    #   super || attributes.key?(method_name)
    # end
  end
end
