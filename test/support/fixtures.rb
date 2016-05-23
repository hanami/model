class User
  include Hanami::Entity
end

class Comment
  include Hanami::Entity
end

Hanami::Model.configure do
  adapter :sql, POSTGRES_CONNECTION_STRING
end

Hanami::Model.migration do
  change do
    drop_table?   :users
    create_table? :users do
      primary_key :id
      column :name, String
      column :comments_count, Integer, null: false, default: 0
    end

    drop_table?   :comments
    create_table? :comments do
      primary_key :id
      foreign_key :user_id, :users, on_delete: :cascade, null: false
      column :text, String
      column :spam, TrueClass, null: false, default: false
    end
  end
end.run

class UserRepository < Hanami::Repository
  relation(:users) do
    schema(infer: true) do
      associate do
        many :comments
      end
    end

    def by_id(id)
      where(id: id)
    end
  end

  mapping do
    model       User
    register_as :entity
  end

  commands :create, update: :by_id, delete: :by_id, mapper: :entity
  relations :comments

  def [](id)
    users.by_id(id).as(:entity).one
  end
  alias_method :find, :[]

  def all
    users.as(:entity)
  end

  def first
    users.as(:entity).first
  end

  def last
    users.order(Sequel.desc(users.primary_key)).as(:entity).first
  end

  def clear
    users.delete
  end

  def find_with_comments(id)
    aggregate(:comments).where(users__id: id).as(User).one
  end

  def by_name(name)
    users.where(name: name).as(:entity)
  end
end

class CommentRepository < Hanami::Repository
  relation(:comments) do
    schema(infer: true)

    def by_id(id)
      where(id: id)
    end
  end

  mapping do
    model       Comment
    register_as :entity
  end

  commands :create, update: :by_id, delete: :by_id, mapper: :entity

  def [](id)
    comments.by_id(id).as(:entity).one
  end
  alias_method :find, :[]

  def all
    comments.as(:entity)
  end
end

Hanami::Model.load!
