class User
  def initialize(attributes = {})
    @name = attributes.values_at(:name)
  end
end

class UserRepository
  def self.persist(*objects)
    records << objects
    records.flatten!
  end

  def self.all
    records
  end

  def self.first
    all.first
  end

  def self.last
    all.last
  end

  def self.clear
    records.clear
  end

  protected
  def self.records
    @@records ||= []
  end
end
