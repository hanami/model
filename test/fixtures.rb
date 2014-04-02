class User
  include Lotus::Entity
  self.attributes = :name
end

class Article
  include Lotus::Entity
  self.attributes = :title, :comments_count
end

class UserRepository
  include Lotus::Repository
end

class ArticleRepository
  include Lotus::Repository
end

DB = Sequel.connect(SQLITE_CONNECTION_STRING)

DB.create_table :user do
  primary_key :id
  String :name
end

DB.create_table :article do
  primary_key :id
  String :title
  String :comments_count # Not an error: we're testing String => Integer coercion
end

#FIXME this should be passed by the framework internals.
MAPPER = Lotus::Model::Mapper.new do
  collection :user do
    entity User

    attribute :id,   Integer
    attribute :name, String
  end

  collection :article do
    entity Article

    attribute :id,             Integer
    attribute :title,          String
    attribute :comments_count, Integer
  end
end
