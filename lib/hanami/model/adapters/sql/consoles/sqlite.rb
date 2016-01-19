require 'shellwords'
module Hanami
  module Model
    module Adapters
      module Sql
        module Consoles
          class Sqlite
            def initialize(uri)
              @uri = uri
            end

            def connection_string
              "sqlite3 #{@uri.host}#{database}"
            end

            private

            def database
              Shellwords.escape(@uri.path)
            end
          end
        end
      end
    end
  end
end
