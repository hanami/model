# frozen_string_literal: true
module Platform
  module Ci
    def self.ci?(name)
      current == name
    end

    def self.current
      if    travis? then :travis
      elsif circle? then :circle
      elsif drone?  then :drone
      end
    end

    class << self
      private

      def travis?
        ENV["TRAVIS"] == "true"
      end

      def circle?
        ENV["CIRCLECI"] == "true"
      end

      def drone?
        ENV["DRONE"] == "true"
      end
    end
  end
end
