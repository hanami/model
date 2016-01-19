module Hanami
  module Model
    module Migrator
      # Sequel connection wrapper
      #
      # Normalize external adapters interfaces
      #
      # @since 0.5.0
      # @api private
      class Connection
        attr_reader :adapter_connection

        def initialize(adapter_connection)
          @adapter_connection = adapter_connection
        end

        # Returns DB connection host
        #
        # Even when adapter doesn't provide it explicitly it tries to parse
        #
        # @since 0.5.0
        # @api private
        def host
          @host ||= opts.fetch(:host, parsed_uri.host)
        end

        # Returns DB connection port
        #
        # Even when adapter doesn't provide it explicitly it tries to parse
        #
        # @since 0.5.0
        # @api private
        def port
          @port ||= opts.fetch(:port, parsed_uri.port)
        end

        # Returns DB name from conenction
        #
        # Even when adapter doesn't provide it explicitly it tries to parse
        #
        # @since 0.5.0
        # @api private
        def database
          @database ||= opts.fetch(:database, parsed_uri.path[1..-1])
        end

        # Returns DB type
        #
        # @example
        #   connection.database_type
        #   # => 'postgres'
        #
        # @since 0.5.0
        # @api private
        def database_type
          adapter_connection.database_type
        end

        # Returns user from DB connection
        #
        # Even when adapter doesn't provide it explicitly it tries to parse
        #
        # @since 0.5.0
        # @api private
        def user
          @user ||= opts.fetch(:user, parsed_opt('user'))
        end

        # Returns user from DB connection
        #
        # Even when adapter doesn't provide it explicitly it tries to parse
        #
        # @since 0.5.0
        # @api private
        def password
          @password ||= opts.fetch(:password, parsed_opt('password'))
        end

        # Returns DB connection URI directly from adapter
        #
        # @since 0.5.0
        # @api private
        def uri
          adapter_connection.uri
        end

        # Returns DB connection wihout specifying database name
        #
        # @since 0.5.0
        # @api private
        def global_uri
          adapter_connection.uri.sub(parsed_uri.select(:path).first, '')
        end

        # Returns a boolean telling if a DB connection is from JDBC or not
        #
        # @since 0.5.0
        # @api private
        def jdbc?
          !adapter_connection.uri.scan('jdbc:').empty?
        end

        # Returns database connection URI instance without JDBC namespace
        #
        # @since 0.5.0
        # @api private
        def parsed_uri
          @uri ||= URI.parse(adapter_connection.uri.sub('jdbc:', ''))
        end

        private

        # Returns a value of a given query string param
        #
        # @param option [String] which option from database connection will be extracted from URI
        #
        # @since 0.5.0
        # @api private
        def parsed_opt(option)
          parsed_uri.to_s.match(/[\?|\&]#{ option }=(\w+)\&?/).to_a.last
        end

        # Fetch connection options from adapter
        #
        # @since 0.5.0
        # @api private
        def opts
          adapter_connection.opts
        end
      end
    end
  end
end
