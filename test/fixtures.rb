class User
  include Lotus::Entity
  self.attributes = :name
end

class Article
  include Lotus::Entity
  self.attributes = :user_id, :title, :comments_count
end

class UserRepository
  include Lotus::Repository
end

class ArticleRepository
  include Lotus::Repository

  def self.by_user(user)
    query do
      where(user_id: user.id)
    end
  end
end

DB = Sequel.connect(SQLITE_CONNECTION_STRING)

DB.create_table :users do
  primary_key :id
  String :name
end

DB.create_table :articles do
  primary_key :identity
  Integer :user_id
  String  :s_title
  String  :comments_count # Not an error: we're testing String => Integer coercion
end

DB.create_table :devices do
  primary_key :id
end


#FIXME this should be passed by the framework internals.
MAPPER = Lotus::Model::Mapper.new do
  collection :users do
    entity User

    attribute :id,   Integer
    attribute :name, String
  end

  collection :articles do
    entity Article

    attribute :id,             Integer, as: :identity
    attribute :user_id,        Integer
    attribute :title,          String,  as: 's_title'
    attribute :comments_count, Integer

    key :identity
  end
end
