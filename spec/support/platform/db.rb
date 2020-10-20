# frozen_string_literal: true
module Platform
  module Db
    def self.db?(name)
      current == name
    end

    def self.current
      Database.engine
    end
  end
end
