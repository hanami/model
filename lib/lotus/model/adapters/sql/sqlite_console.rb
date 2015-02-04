module Lotus
  module Model
    module Adapters
      module Sql
        class SqliteConsole
          def initialize(uri, options = {})
            @uri = uri
            @options = options
          end

          def connection_string
            "sqlite3 #{host}#{database}"
          end

          private

          def host
            @options.fetch('host') { @uri.host }
          end

          def database
            @options.fetch('database') { @uri.path }
          end
        end
      end
    end
  end
end
