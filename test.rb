# frozen_string_literal: true

require "bundler/setup"
require "dry/types"
require "dry/struct"

module Techno
  # Types
  module Types
    include Dry.Types
  end

  # Schemaless entity
  class Schemaless < Dry::Struct
    def self.load(attributes)
      return attributes if attributes.is_a?(self)

      super
    end

    class << self
      alias new load
      alias call load
      alias call_unsafe load
    end

    def method_missing(method_name, *args)
      if args.empty? && attributes.key?(method_name)
        attributes[method_name]
      else
        super
      end
    end

    def respond_to_missing?(method_name, _)
      super || attributes.key?(method_name)
    end

    def inspect
      "#<#{self.class.name} #{attributes.map { |k, v| "#{k}=#{v.inspect}" }.join(' ')}>"
    end
    alias to_s inspect
  end

  # Entity
  class Entity < Dry::Struct
    def self.[](type)
      case type
      when :struct
        Schemaless
      end
    end
  end
end

class User < Techno::Entity[:struct]
end

# Account
class Account < Techno::Entity
  attribute :name, Techno::Types::String
  attribute :owner, Techno::Types.Constructor(User)
  attribute :users, Techno::Types.Array(User)
end

user = User.new(name: "Luca", age: "37")
puts user.inspect

account = Account.new(name: "Hanami", owner: { name: "Luca" }, users: [{ name: "MG" }])
puts account.inspect

account = Account.new(name: "Hanami", owner: user, users: [{ name: "MG" }])
puts account.inspect
