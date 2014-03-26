class User
  include Lotus::Entity
  self.attributes = :name
end

class Article
  include Lotus::Entity
  self.attributes = :title
end

class UserRepository
  include Lotus::Repository
end

class ArticleRepository
  include Lotus::Repository
end
