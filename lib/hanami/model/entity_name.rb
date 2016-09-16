module Hanami
  module Model
    class EntityName
      SUFFIX = /Repository\z/

      def self.new(name)
        name.gsub(SUFFIX, '')
      end
    end
  end
end
