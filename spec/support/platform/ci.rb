module Platform
  module Ci
    def self.ci?(name)
      current == name
    end

    def self.current
      if    travisci?  then :travisci
      elsif circleci?  then :circleci
      end
    end

    class << self
      private

      def travisci?
        ENV['TRAVIS'] == 'true'
      end

      def circleci?
        ENV['CIRCLECI'] == 'true'
      end
    end
  end
end
