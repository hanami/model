require 'concurrent'

module Hanami
  module Model
    # Default Error class
    #
    # @since 0.5.1
    class Error < ::StandardError
      # @api private
      # @since x.x.x
      @__mapping__ = Concurrent::Map.new

      # @api private
      # @since x.x.x
      def self.for(exception)
        mapping.fetch(exception.class, self).new(exception)
      end

      # @api private
      # @since x.x.x
      def self.register(external, internal)
        mapping.put_if_absent(external, internal)
      end

      # @api private
      # @since x.x.x
      def self.mapping
        @__mapping__
      end
    end

    # Generic database error
    #
    # @since x.x.x
    class DatabaseError < Error
    end

    # Error for invalid raw command syntax
    #
    # @since 0.5.0
    class InvalidCommandError < Error
      def initialize(message = 'Invalid command')
        super
      end
    end

    # Error for Constraint Violation
    #
    # @since x.x.x
    class ConstraintViolationError < Error
      def initialize(message = 'Constraint has been violated')
        super
      end
    end

    # Error for Unique Constraint Violation
    #
    # @since 0.6.1
    class UniqueConstraintViolationError < Error
      def initialize(message = 'Unique constraint has been violated')
        super
      end
    end

    # Error for Foreign Key Constraint Violation
    #
    # @since 0.6.1
    class ForeignKeyConstraintViolationError < Error
      def initialize(message = 'Foreign key constraint has been violated')
        super
      end
    end

    # Error for Not Null Constraint Violation
    #
    # @since 0.6.1
    class NotNullConstraintViolationError < Error
      def initialize(message = 'NOT NULL constraint has been violated')
        super
      end
    end

    # Error for Check Constraint Violation raised by Sequel
    #
    # @since 0.6.1
    class CheckConstraintViolationError < Error
      def initialize(message = 'Check constraint has been violated')
        super
      end
    end
  end
end
