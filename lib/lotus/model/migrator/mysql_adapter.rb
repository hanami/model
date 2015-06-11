module Lotus
  module Model
    module Migrator
      class MySQLAdapter < Adapter
        def create
          new_connection.run %(CREATE DATABASE #{ database };)
        end

        def drop
          new_connection.run %(DROP DATABASE #{ database };)
        rescue Sequel::DatabaseError => e
          message = if e.message.match(/doesn\'t exist/)
            "Cannot find database: #{ database }"
          else
            e.message
          end

          raise MigrationError.new(message)
        end
      end
    end
  end
end
