require "hanami/utils/basic_object"

module Platform
  class Matcher
    class Nope < Hanami::Utils::BasicObject
      def or(other, &blk)
        blk.nil? ? other : blk.call
      end

      # rubocop:disable Style/MethodMissingSuper
      # rubocop:disable Style/MissingRespondToMissing
      def method_missing(*)
        self.class.new
      end
      # rubocop:enable Style/MissingRespondToMissing
      # rubocop:enable Style/MethodMissingSuper
    end

    def self.match(&blk)
      catch :match do
        new.__send__(:match, &blk)
      end
    end

    def self.match?(os: Os.current, ci: Ci.current, engine: Engine.current, db: Db.current)
      catch :match do
        new.os(os).ci(ci).engine(engine).db(db) { true }.or(false)
      end
    end

    def initialize
      freeze
    end

    def os(name, &blk)
      return nope unless os?(name)

      block_given? ? resolve(&blk) : yep
    end

    def ci(name, &blk)
      return nope unless ci?(name)

      block_given? ? resolve(&blk) : yep
    end

    def engine(name, &blk)
      return nope unless engine?(name)

      block_given? ? resolve(&blk) : yep
    end

    def db(name, &blk)
      return nope unless db?(name)

      block_given? ? resolve(&blk) : yep
    end

    def default(&blk)
      resolve(&blk)
    end

    private

    def match(&blk)
      instance_exec(&blk)
    end

    def nope
      Nope.new
    end

    def yep
      self.class.new
    end

    def resolve
      throw :match, yield
    end

    def os?(name)
      Os.os?(name)
    end

    def ci?(name)
      Ci.ci?(name)
    end

    def engine?(name)
      Engine.engine?(name)
    end

    def db?(name)
      Db.db?(name)
    end
  end
end
