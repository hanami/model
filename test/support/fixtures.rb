class User
  include Hanami::Entity
end

class Comment
  include Hanami::Entity
end

Hanami::Model.configure do
  adapter :sql, 'sqlite::memory'
end

Hanami::Model.migration do
  change do
    create_table :users do
      primary_key :id
      column :name, String
    end

    create_table :comments do
      primary_key :id
      foreign_key :user_id, :users, on_delete: :cascade, null: false
      column :text, String
    end
  end
end.run

class UserRepository < Hanami::Repository
  relation(:users) do
    schema do
      attribute :id, ROM::SQL::Types::Serial # We can copy these types to Hanami
      attribute :name, ROM::SQL::Types::String # We can copy these types to Hanami

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

  def [](id)
    users.by_id(id).as(:entity).one
  end
  alias_method :find, :[]

  def all
    users.as(:entity)
  end

  def find_with_comments(id)
    aggregate(:comments).by_id(id).one
  end
end

class CommentRepository < Hanami::Repository
  relation(:comments) do
    schema do
      attribute :id, ROM::SQL::Types::Serial # We can copy these types to Hanami
      attribute :user_id, ROM::SQL::Types::ForeignKey(:users) # We can copy these types to Hanami
      attribute :text, ROM::SQL::Types::String # We can copy these types to Hanami
    end

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
