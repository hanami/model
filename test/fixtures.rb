class User
  include Lotus::Entity
  attributes :name, :age, :created_at, :updated_at
end

class Article
  include Lotus::Entity
  include Lotus::Entity::DirtyTracking
  attributes :user_id, :unmapped_attribute, :title, :comments_count
end

class Repository
  include Lotus::Entity
  attributes :id, :name
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
end

def create_tables_per_database(database)
  database.create_table? :users do
    primary_key :id
    Integer :country_id
    String  :name
    Integer :age
    DateTime :created_at
    DateTime :updated_at
  end

  database.create_table? :articles do
    primary_key :_id
    Integer :user_id
    String  :s_title
    String  :comments_count # Not an error: we're testing String => Integer coercion
    String  :umapped_column
  end

  database.create_table? :devices do
    primary_key :id
    Integer     :u_id # user_id: legacy schema simulation
  end

  database.create_table? :orders do
    primary_key :id
    Integer :user_id
    Integer :total
  end

  database.create_table? :ages do
    primary_key :id
    Integer :value
    String  :label
  end

  database.create_table? :countries do
    primary_key :country_id
    String :code
  end
end

DB = Sequel.connect(SQLITE_CONNECTION_STRING)
create_tables_per_database(DB)

#FIXME this should be passed by the framework internals.
MAPPER = Lotus::Model::Mapper.new do
  collection :users do
    entity User

    attribute :id,         Integer
    attribute :name,       String
    attribute :age,        Integer
    attribute :created_at, DateTime
    attribute :updated_at, DateTime
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
