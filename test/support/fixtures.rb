class User
  include Hanami::Entity
end

class Avatar
  include Hanami::Entity
end

class Author
  include Hanami::Entity
end

class Book
  include Hanami::Entity
end

class Operator
  include Hanami::Entity
end

class SourceFile
  include Hanami::Entity
end

class UserRepository < Hanami::Repository
  commands :create, update: :by_primary_key, delete: :by_primary_key, mapper: :entity, use: [:mapping, :timestamps]

  def by_name(name)
    users.where(name: name).as(:entity)
  end
end

class AvatarRepository < Hanami::Repository
  commands :create, update: :by_primary_key, delete: :by_primary_key, mapper: :entity, use: [:mapping, :timestamps]
end

class AuthorRepository < Hanami::Repository
  associations do
    has_many :books
  end

  commands :create, update: :by_primary_key, delete: :by_primary_key, mapper: :entity, use: [:mapping, :timestamps]

  def find_with_books(id)
    aggregate(:books).where(authors__id: id).as(Author).one
  end

  def books_for(author)
    assoc(:books, author)
  end

  def add_book(author, data)
    assoc(:books, author).add(data)
  end

  def remove_book(author, id)
    assoc(:books, author).remove(id)
  end

  def delete_books(author)
    assoc(:books, author).delete
  end

  def delete_on_sales_books(author)
    assoc(:books, author).where(on_sale: true).delete
  end

  def books_count(author)
    assoc(:books, author).count
  end

  def on_sales_books_count(author)
    assoc(:books, author).where(on_sale: true).count
  end

  def find_book(author, id)
    book_for(author, id).one
  end

  def book_exists?(author, id)
    book_for(author, id).exists?
  end

  private

  def book_for(author, id)
    assoc(:books, author).where(id: id)
  end
end

class BookRepository < Hanami::Repository
  associations do
    belongs_to :author
  end

  commands :create, update: :by_primary_key, delete: :by_primary_key, mapper: :entity, use: [:mapping, :timestamps]
end

class OperatorRepository < Hanami::Repository
  self.relation = :t_operator

  mapping do
    attribute :id,   from: :operator_id
    attribute :name, from: :s_name
  end

  commands :create, update: :by_primary_key, delete: :by_primary_key, mapper: :entity, use: [:mapping, :timestamps]
end

class SourceFileRepository < Hanami::Repository
  commands :create, update: :by_primary_key, delete: :by_primary_key, mapper: :entity, use: [:timestamps, :mapping]
end

Hanami::Model.load!
