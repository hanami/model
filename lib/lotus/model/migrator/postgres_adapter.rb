module Lotus
  module Model
    module Migrator
      class PostgresAdapter < Adapter
        def create
          new_connection.run %(CREATE DATABASE "#{ database }"#{ create_options })
        end

        def drop
          new_connection.run %(DROP DATABASE "#{ database }")
        rescue Sequel::DatabaseError => e
          message = if e.message.match(/does not exist/)
            "Cannot find database: #{ database }"
          else
            e.message
          end

          raise MigrationError.new(message)
        end

        private
        def create_options
          result  = ""
          result += %( OWNER "#{ options.fetch(:user) }") if options.fetch(:user, nil)
          result
        end
      end
    end
  end
end
