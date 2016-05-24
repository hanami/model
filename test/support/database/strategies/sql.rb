require_relative 'abstract'

module Database
  module Strategies
    class Sql < Abstract
      def self.eligible?(_adapter)
        false
      end

      protected

      def export_env
        super
        ENV['HANAMI_DATABASE_ADAPTER'] = 'sql'
      end

      def after
        require_relative '../../fixtures/migrations'
        puts "Testing with `#{ENV['HANAMI_DATABASE_ADAPTER']}' adapter (#{ENV['HANAMI_DATABASE_TYPE']}) - jruby: #{jruby?}, ci: #{ci?}"
        puts "Env: #{ENV.inspect}" if ci?
      end
    end
  end
end
