class User
  include Lotus::Entity
  self.attributes = :name, :age
end

class Article
  include Lotus::Entity
  self.attributes = :user_id, :unmapped_attribute, :title, :comments_count
end

class CustomUserRepository
  include Lotus::Repository
end

class UserRepository
  include Lotus::Repository
end

class UnmappedRepository
  include Lotus::Repository
end

class ArticleRepository
  include Lotus::Repository

  def self.rank
    query do
      desc(:comments_count)
    end
  end

  def self.by_user(user)
    query do
      where(user_id: user.id)
    end
  end

  def self.not_by_user(user)
    exclude by_user(user)
  end

  def self.rank_by_user(user)
    rank.by_user(user)
  end
end

DB = Sequel.connect(SQLITE_CONNECTION_STRING)

DB.create_table :users do
  primary_key :id
  Integer :country_id
  String  :name
  Integer :age
end

DB.create_table :articles do
  primary_key :_id
  Integer :user_id
  String  :s_title
  String  :comments_count # Not an error: we're testing String => Integer coercion
  String  :umapped_column
end

DB.create_table :devices do
  primary_key :id
  Integer     :u_id # user_id: legacy schema simulation
end

DB.create_table :orders do
  primary_key :id
  Integer :user_id
  Integer :total
end

DB.create_table :ages do
  primary_key :id
  Integer :value
  String  :label
end

DB.create_table :countries do
  primary_key :country_id
  String :code
end

# DB.dataset_class = Class.new(Sequel::Dataset)

#FIXME this should be passed by the framework internals.
MAPPER = Lotus::Model::Mapper.new do
  collection :users do
    entity User

    attribute :id,   Integer
    attribute :name, String
    attribute :age,  Integer
  end

  collection :articles do
    entity Article

    attribute :id,             Integer, as: :_id
    attribute :user_id,        Integer
    attribute :title,          String,  as: 's_title'
    attribute :comments_count, Integer

    identity :_id
  end
end

MAPPER.load!
