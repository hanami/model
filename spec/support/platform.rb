module Platform
  require_relative "platform/os"
  require_relative "platform/ci"
  require_relative "platform/engine"
  require_relative "platform/db"
  require_relative "platform/matcher"

  def self.ci?
    !Ci.current.nil?
  end

  def self.match(&blk)
    Matcher.match(&blk)
  end

  def self.match?(**args)
    Matcher.match?(**args)
  end
end

module PlatformHelpers
  def with_platform(**args)
    yield if Platform.match?(**args)
  end

  def unless_platform(**args)
    yield unless Platform.match?(**args)
  end
end
