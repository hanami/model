require 'cgi'

module Hanami
  module Model
    class Migrator
      # Sequel connection wrapper
      #
      # Normalize external adapters interfaces
      #
      # @since 0.5.0
      # @api private
      class Connection
        # @since 0.5.0
        # @api private
        def initialize(configuration)
          @configuration = configuration
        end

        # @since 0.7.0
        # @api private
        def raw
          @raw ||= begin
                     Sequel.connect(
                       configuration.url,
                       loggers: [configuration.migrations_logger]
                     )
                   rescue Sequel::AdapterNotFound
                     raise MigrationError.new("Current adapter (#{configuration.adapter.type}) doesn't support SQL database operations.")
                   end
        end

        # Returns DB connection host
        #
        # Even when adapter doesn't provide it explicitly it tries to parse
        #
        # @since 0.5.0
        # @api private
        def host
          @host ||= parsed_uri.host || parsed_opt('host')
        end

        # Returns DB connection port
        #
        # Even when adapter doesn't provide it explicitly it tries to parse
        #
        # @since 0.5.0
        # @api private
        def port
          @port ||= parsed_uri.port || parsed_opt('port').to_i.nonzero?
        end

        # Returns DB name from conenction
        #
        # Even when adapter doesn't provide it explicitly it tries to parse
        #
        # @since 0.5.0
        # @api private
        def database
          @database ||= parsed_uri.path[1..-1]
        end

        # Returns DB type
        #
        # @example
        #   connection.database_type
        #     # => 'postgres'
        #
        # @since 0.5.0
        # @api private
        def database_type
          case uri
          when /sqlite/
            :sqlite
          when /postgres/
            :postgres
          when /mysql/
            :mysql
          end
        end

        # Returns user from DB connection
        #
        # Even when adapter doesn't provide it explicitly it tries to parse
        #
        # @since 0.5.0
        # @api private
        def user
          @user ||= parsed_opt('user') || parsed_uri.user
        end

        # Returns user from DB connection
        #
        # Even when adapter doesn't provide it explicitly it tries to parse
        #
        # @since 0.5.0
        # @api private
        def password
          @password ||= parsed_opt('password') || parsed_uri.password
        end

        # Returns DB connection URI directly from adapter
        #
        # @since 0.5.0
        # @api private
        def uri
          @configuration.url
        end

        # Returns DB connection wihout specifying database name
        #
        # @since 0.5.0
        # @api private
        def global_uri
          uri.sub(parsed_uri.select(:path).first, '')
        end

        # Returns a boolean telling if a DB connection is from JDBC or not
        #
        # @since 0.5.0
        # @api private
        def jdbc?
          !uri.scan('jdbc:').empty?
        end

        # Returns database connection URI instance without JDBC namespace
        #
        # @since 0.5.0
        # @api private
        def parsed_uri
          @parsed_uri ||= URI.parse(uri.sub('jdbc:', ''))
        end

        # @api private
        def schema
          configuration.schema
        end

        # Return the database table for the given name
        #
        # @since 0.7.0
        # @api private
        def table(name)
          raw[name] if raw.tables.include?(name)
        end

        private

        # @since 1.0.0
        # @api private
        attr_reader :configuration

        # Returns a value of a given query string param
        #
        # @param option [String] which option from database connection will be extracted from URI
        #
        # @since 0.5.0
        # @api private
        def parsed_opt(option, query: parsed_uri.query)
          return if query.nil?

          @parsed_query_opts ||= CGI.parse(query)
          @parsed_query_opts[option].to_a.last
        end
      end
    end
  end
end
