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
      # @since 0.5.0
      # @api private
      def initialize(message = 'Invalid command')
        super
      end
    end

    # Error for Constraint Violation
    #
    # @since 0.7.0
    class ConstraintViolationError < Error
      # @since 0.7.0
      # @api private
      def initialize(message = 'Constraint has been violated')
        super
      end
    end

    # Error for Unique Constraint Violation
    #
    # @since 0.6.1
    class UniqueConstraintViolationError < ConstraintViolationError
      # @since 0.6.1
      # @api private
      def initialize(message = 'Unique constraint has been violated')
        super
      end
    end

    # Error for Foreign Key Constraint Violation
    #
    # @since 0.6.1
    class ForeignKeyConstraintViolationError < ConstraintViolationError
      # @since 0.6.1
      # @api private
      def initialize(message = 'Foreign key constraint has been violated')
        super
      end
    end

    # Error for Not Null Constraint Violation
    #
    # @since 0.6.1
    class NotNullConstraintViolationError < ConstraintViolationError
      # @since 0.6.1
      # @api private
      def initialize(message = 'NOT NULL constraint has been violated')
        super
      end
    end

    # Error for Check Constraint Violation raised by Sequel
    #
    # @since 0.6.1
    class CheckConstraintViolationError < ConstraintViolationError
      # @since 0.6.1
      # @api private
      def initialize(message = 'Check constraint has been violated')
        super
      end
    end

    # Unknown database type error for repository auto-mapping
    #
    # @since 1.0.0
    class UnknownDatabaseTypeError < Error
    end

    # Unknown primary key error
    #
    # @since 1.0.0
    class MissingPrimaryKeyError < Error
    end
  end
end
