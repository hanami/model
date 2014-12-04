require 'lotus/utils/kernel'

module Lotus
  module Model
    module Config
      # Read mapping file for mapping DSL
      #
      # @since 0.2.0
      # @api private
      class Mapper
        EXTNAME = '.rb'

        def initialize(path)
          @path = root.join(path)
        end

        def to_proc
          code = realpath.read
          Proc.new { eval(code) }
        end

        private
        def realpath
          Utils::Kernel.Pathname("#{ @path }#{ EXTNAME }").realpath
        rescue Errno::ENOENT
          raise ArgumentError, error_message
        end

        def error_message
          'You must specify a file.'
        end

        def root
          Utils::Kernel.Pathname(Dir.pwd).realpath
        end
      end
    end
  end
end
