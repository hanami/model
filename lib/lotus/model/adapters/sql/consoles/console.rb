module Lotus
  module Model
    module Adapters
      module Sql
        module Consoles
          class Console
            def initialize(uri)
              @uri = uri
            end

            protected

            def host
              Shellwords.escape(@uri.host)
            end

            def database
              @uri.path
            end

            def port
              @uri.port
            end
          end
        end
      end
    end
  end
end
