module Hanami
  module Model
    module Adapters
      module Memory
        # Acts like a SQL database table.
        #
        # @api private
        # @since 0.1.0
        class Collection
          # A counter that simulates autoincrement primary key of a SQL table.
          #
          # @api private
          # @since 0.1.0
          class PrimaryKey
            # Initialize
            #
            # @return [Hanami::Model::Adapters::Memory::Collection::PrimaryKey]
            #
            # @api private
            # @since 0.1.0
            def initialize
              @current = 0
            end

            # Increment the current count by 1 and yields the given block
            #
            # @return [Fixnum] the incremented counter
            #
            # @api private
            # @since 0.1.0
            def increment!
              yield(@current += 1)
              @current
            end
          end

          # @attr_reader name [Symbol] the name of the collection (eg. `:users`)
          #
          # @since 0.1.0
          # @api private
          attr_reader :name

          # @attr_reader identity [Symbol] the primary key of the collection
          #   (eg. `:id`)
          #
          # @since 0.1.0
          # @api private
          attr_reader :identity

          # @attr_reader records [Hash] a set of records
          #
          # @since 0.1.0
          # @api private
          attr_reader :records

          # Initialize a collection
          #
          # @param name [Symbol] the name of the collection (eg. `:users`).
          # @param identity [Symbol] the primary key of the collection
          #   (eg. `:id`).
          #
          # @api private
          # @since 0.1.0
          def initialize(name, identity)
            @name, @identity = name, identity
            clear
          end

          # Creates a record for the given entity and assigns an id.
          #
          # @param entity [Object] the entity to persist
          #
          # @see Hanami::Model::Adapters::Memory::Command#create
          #
          # @return the primary key of the created record
          #
          # @api private
          # @since 0.1.0
          def create(entity)
            @primary_key.increment! do |id|
              entity[identity] = id
              records[id] = entity
            end
          end

          # Updates the record corresponding to the given entity.
          #
          # @param entity [Object] the entity to persist
          #
          # @see Hanami::Model::Adapters::Memory::Command#update
          #
          # @api private
          # @since 0.1.0
          def update(entity)
            records[entity.fetch(identity)] = entity
          end

          # Deletes the record corresponding to the given entity.
          #
          # @param entity [Object] the entity to delete
          #
          # @see Hanami::Model::Adapters::Memory::Command#delete
          #
          # @api private
          # @since 0.1.0
          def delete(entity)
            records.delete(entity.id)
          end

          # Returns all the raw records
          #
          # @return [Array<Hash>]
          #
          # @api private
          # @since 0.1.0
          def all
            records.values
          end

          # Deletes all the records and resets the identity counter.
          #
          # @api private
          # @since 0.1.0
          def clear
            @records     = {}
            @primary_key = PrimaryKey.new
          end
        end
      end
    end
  end
end
