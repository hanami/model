require 'concurrent'

module Hanami
  module Model
    # Default Error class
    #
    # @since 0.5.1
    class Error < ::StandardError
      # @api private
      # @since 0.7.0
      @__mapping__ = Concurrent::Map.new

      # @api private
      # @since 0.7.0
      def self.for(exception)
        mapping.fetch(exception.class, self).new(exception)
      end

      # @api private
      # @since 0.7.0
      def self.register(external, internal)
        mapping.put_if_absent(external, internal)
      end

      # @api private
      # @since 0.7.0
      def self.mapping
        @__mapping__
      end
    end

    # Generic database error
    #
    # @since 0.7.0
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
    # @since 0.7.0
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

    # Unknown database type error for repository auto-mapping
    #
    # @since x.x.x
    class UnknownDatabaseTypeError < Error
      def initialize(message)
        super
      end
    end
  end
end
