class User
  def initialize(attributes = {})
    @id, @name = attributes.values_at(:id, :name)
  end

  protected
  attr_accessor :id, :name
end

class Article
  def initialize(attributes = {})
    @id, @title = attributes.values_at(:id, :title)
  end

  protected
  attr_accessor :id
end

class UserRepository
  include Lotus::Model::Repository
  self.adapter = Lotus::Model::Adapters::Memory.new
end

class ArticleRepository
  include Lotus::Model::Repository
  self.adapter = Lotus::Model::Adapters::Memory.new
end
