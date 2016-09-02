require 'hanami/utils'

module Platform
  def self.ci?
    ENV['TRAVIS'] == 'true'
  end

  def self.jruby?
    Hanami::Utils.jruby?
  end
end
