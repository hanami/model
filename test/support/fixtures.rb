class User
  include Hanami::Entity
end

class Comment
  include Hanami::Entity
end

class Operator
  include Hanami::Entity
end

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

  commands :create, update: :by_id, delete: :by_id, mapper: :entity, use: :timestamps
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

  commands :create, update: :by_id, delete: :by_id, mapper: :entity, use: :timestamps

  def [](id)
    comments.by_id(id).as(:entity).one
  end
  alias_method :find, :[]

  def all
    comments.as(:entity)
  end
end

class OperatorRepository < Hanami::Repository
  relation(:t_operator) do
    schema(infer: true) do
      # associate do
      #   many :comments
      # end
    end

    def by_id(id)
      where(operator_id: id)
    end
  end

  mapping do
    model       Operator
    register_as :entity

    attribute :id,   from: :operator_id
    attribute :name, from: :s_name
  end

  commands :create, update: :by_id, delete: :by_id, mapper: :entity, use: [:mapping, :timestamps]

  def [](id)
    t_operator.by_id(id).as(:entity).one
  end
  alias_method :find, :[]
end

Hanami::Model.load!
