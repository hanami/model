
module Database
  class Setup
    DEFAULT_ADAPTER = 'sqlite'.freeze

    def initialize(adapter: ENV['DB'])
      @strategy = Strategy.for(adapter || DEFAULT_ADAPTER)
    end

    def run
      @strategy.run
    end
  end

  module Strategies
    require_relative './database/strategies/sqlite'
    require_relative './database/strategies/postgresql'
    require_relative './database/strategies/mysql'

    def self.strategies
      constants.map do |const|
        const_get(const)
      end
    end
  end

  class Strategy
    class << self
      def for(adapter)
        strategies.find do |strategy|
          strategy.eligible?(adapter)
        end.new
      end

      private

      def strategies
        Strategies.strategies
      end
    end
  end
end

Database::Setup.new.run
