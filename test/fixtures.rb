require 'sequel/extensions/pg_array'

class User
  include Lotus::Entity
  attributes :name, :age, :created_at, :updated_at, :articles
end

class Article
  include Lotus::Entity
  include Lotus::Entity::DirtyTracking
  attributes :user_id, :unmapped_attribute, :title, :comments_count, :tags, :category_id, :user, :category
end

class Category
  include Lotus::Entity
  attributes :article
end

class Repository
  include Lotus::Entity
  attributes :id, :name
end

class CustomUserRepository
  include Lotus::Repository
end

class CategoryRepository
  include Lotus::Repository
end

class UserRepository
  include Lotus::Repository

  def self.all_with_articles
    query.preload(:articles)
  end
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

  def self.by_category(category)
    query do
      where(category_id: category.id)
    end
  end

  def self.not_by_user(user)
    exclude by_user(user)
  end

  def self.rank_by_user(user)
    rank.by_user(user)
  end

  def self.reset_comments_count
    execute("UPDATE articles SET comments_count = '0'")
  end

  def self.find_raw
    fetch("SELECT * FROM articles")
  end

  def self.each_titles
    result = []

    fetch("SELECT s_title FROM articles") do |article|
      result << article[:s_title]
    end

    result
  end

  def self.map_titles
    fetch("SELECT s_title FROM articles").map do |article|
      article[:s_title]
    end
  end

  def self.all_with_category
    query do
      preload(:category)
    end
  end

  def self.all_with_user
    query do
      preload(:user)
    end
  end

  def self.all_with_user_and_category
    query.preload(:user).preload(:category)
  end
end

[SQLITE_CONNECTION_STRING, POSTGRES_CONNECTION_STRING].each do |conn_string|
  require 'lotus/utils/io'

  Lotus::Utils::IO.silence_warnings do
    DB = Sequel.connect(conn_string)
  end

  DB.create_table :users do
    primary_key :id
    Integer :country_id
    String  :name
    Integer :age
    DateTime :created_at
    DateTime :updated_at
  end

  DB.create_table :categories do
    primary_key :id
  end

  DB.create_table :articles do
    primary_key :_id
    Integer :user_id
    Integer :category_id
    String  :s_title
    String  :comments_count # Not an error: we're testing String => Integer coercion
    String  :umapped_column

    if conn_string.match(/\Apostgres/)
      column :tags, 'text[]'
    else
      column :tags, String
    end
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
end

class PGArray < Lotus::Model::Coercer
  def self.dump(value)
    ::Sequel.pg_array(value) rescue nil
  end

  def self.load(value)
    ::Kernel.Array(value) unless value.nil?
  end
end

#FIXME this should be passed by the framework internals.
MAPPER = Lotus::Model::Mapper.new do
  collection :users do
    entity User

    attribute :id,         Integer
    attribute :name,       String
    attribute :age,        Integer
    attribute :created_at, DateTime
    attribute :updated_at, DateTime
    association :articles, [Article], foreign_key: :user_id, collection: :articles
  end

  collection :categories do
    entity Category

    attribute :id, Integer
  end

  collection :articles do
    entity Article

    attribute :id,             Integer, as: :_id
    attribute :user_id,        Integer
    attribute :category_id,    Integer
    attribute :title,          String,  as: 's_title'
    attribute :comments_count, Integer
    attribute :tags,           PGArray
    association :user, User, foreign_key: :user_id, collection: :users
    association :category, Category, foreign_key: :category_id, collection: :categories

    identity :_id
  end

end

MAPPER.load!
