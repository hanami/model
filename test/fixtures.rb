class User
  def initialize(attributes = {})
    @name = attributes.values_at(:name)
  end
end

class Article
  def initialize(attributes = {})
    @title = attributes.values_at(:title)
  end
end

class UserRepository
  include Lotus::Model::Repository
end

class ArticleRepository
  include Lotus::Model::Repository
end
