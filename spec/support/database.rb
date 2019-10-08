# frozen_string_literal: true

module Database
  class Setup
    DEFAULT_ADAPTER = "sqlite"

    def initialize(adapter: ENV["DB"])
      @strategy = Strategy.for(adapter || DEFAULT_ADAPTER)
    end

    def run
      @strategy.run
    end
  end

  module Strategies
    require_relative "./database/strategies/sqlite"
    require_relative "./database/strategies/postgresql"
    require_relative "./database/strategies/mysql"

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

  def self.engine
    ENV["HANAMI_DATABASE_TYPE"].to_sym
  end

  def self.engine?(name)
    engine == name.to_sym
  end
end

# rubocop:disable Style/GlobalVars
$config = Database::Setup.new.run

module RSpec
  module Support
    module Context
      def self.included(base)
        base.class_eval do
          let(:configuration) { $config }
        end
      end
    end
  end
end
# rubocop:enable Style/GlobalVars

RSpec.configure do |config|
  config.include(RSpec::Support::Context)
end
