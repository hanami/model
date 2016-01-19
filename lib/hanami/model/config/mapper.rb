require 'hanami/utils/kernel'

module Hanami
  module Model
    module Config
      # Read mapping file for mapping DSL
      #
      # @since 0.2.0
      # @api private
      class Mapper
        EXTNAME = '.rb'

        def initialize(path=nil, &blk)
          if block_given?
            @blk = blk
          elsif path
            @path = root.join(path)
          else
            raise Hanami::Model::InvalidMappingError.new('You must specify a block or a file.')
          end
        end

        def to_proc
          unless @blk
            code = realpath.read
            @blk = Proc.new { eval(code) }
          end

          @blk
        end

        private
        def realpath
          Utils::Kernel.Pathname("#{ @path }#{ EXTNAME }").realpath
        rescue Errno::ENOENT
          raise ArgumentError, 'You must specify a valid filepath.'
        end

        def root
          Utils::Kernel.Pathname(Dir.pwd).realpath
        end
      end
    end
  end
end
