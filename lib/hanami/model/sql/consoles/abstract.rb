module Hanami
  module Model
    module Sql
      module Consoles
        # Abstract adapter
        #
        # @since 0.7.0
        # @api private
        class Abstract
          # @since 0.7.0
          # @api private
          def initialize(uri)
            @uri = uri
          end

          private

          # @since 0.7.0
          # @api private
          def database_name
            @uri.path.sub(/^\//, '')
          end

          # @since 0.7.0
          # @api private
          def concat(*tokens)
            tokens.join
          end
        end
      end
    end
  end
end
