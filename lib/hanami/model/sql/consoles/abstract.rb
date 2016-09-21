module Hanami
  module Model
    module Sql
      module Consoles
        # Abstract adapter
        #
        # @since x.x.x
        # @api private
        class Abstract
          # @since x.x.x
          # @api private
          def initialize(uri)
            @uri = uri
          end

          private

          # @since x.x.x
          # @api private
          def database_name
            @uri.path.sub(/^\//, '')
          end

          # @since x.x.x
          # @api private
          def concat(*tokens)
            tokens.compact.join
          end
        end
      end
    end
  end
end
