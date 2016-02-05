module Hanami
  module Model

    # Default Error class
    #
    # @since 0.5.1
    Error = Class.new(::StandardError)

    # Error for non persisted entity
    # It's raised when we try to update or delete a non persisted entity.
    #
    # @since 0.1.0
    #
    # @see Hanami::Repository.update
    NonPersistedEntityError = Class.new(Error)

    # Error for invalid mapper configuration
    # It's raised when mapping is not configured correctly
    #
    # @since 0.2.0
    #
    # @see Hanami::Configuration#mapping
    InvalidMappingError = Class.new(Error)

    # Error for invalid raw command syntax
    #
    # @since 0.5.0
    class InvalidCommandError < Error
      def initialize(message = "Invalid command")
        super
      end
    end

    # Error for invalid raw query syntax
    #
    # @since 0.3.1
    class InvalidQueryError < Error
      def initialize(message = "Invalid query")
        super
      end
    end

    # Error for Unique Constraint Violation
    #
    # @since 0.6.1
    class UniqueConstraintViolationError < Error
      def initialize(message = "Unique constraint has been violated")
        super
      end
    end

    # Error for Foreign Key Constraint Violation
    #
    # @since 0.6.1
    class ForeignKeyConstraintViolationError < Error
      def initialize(message = "Foreign key constraint has been violated")
        super
      end
    end

    # Error for Not Null Constraint Violation
    #
    # @since 0.6.1
    class NotNullConstraintViolationError < Error
      def initialize(message = "NOT NULL constraint has been violated")
        super
      end
    end

    # Error for Check Constraint Violation raised by Sequel
    #
    # @since 0.6.1
    class CheckConstraintViolationError < Error
      def initialize(message = "Check constraint has been violated")
        super
      end
    end
  end
end
