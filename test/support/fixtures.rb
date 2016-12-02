class User < Hanami::Entity
end

class Avatar < Hanami::Entity
end

class Author < Hanami::Entity
end

class Book < Hanami::Entity
end

class Operator < Hanami::Entity
end

class SourceFile < Hanami::Entity
end

class Wharehouse < Hanami::Entity
  attributes do
    attribute :id,   Types::Int
    attribute :name, Types::String
    attribute :code, Types::String.constrained(format: /\Awh\-/)
  end
end

class Account < Hanami::Entity
  attributes do
    attribute :id,         Types::Strict::Int
    attribute :name,       Types::String
    attribute :codes,      Types::Collection(Types::Coercible::Int)
    attribute :users,      Types::Collection(User)
    attribute :email,      Types::String.constrained(format: /@/)
    attribute :created_at, Types::DateTime.constructor(->(dt) { ::DateTime.parse(dt.to_s) })
  end
end

class Product < Hanami::Entity
end

class UserRepository < Hanami::Repository
  def by_name(name)
    users.where(name: name).as(:entity)
  end

  def find_all_by_manual_query
    connection.fetch('select * from users').to_a
  end

  def active_users
    users.where(active: true)
  end

  def count
    users.count
  end

  def count_with_connection
    connection[:users].count
  end

  def count_active_users
    active_users.count
  end

  def reset_comments_count
    connection.execute('UPDATE users SET comments_count = 0')
  end
end

class AvatarRepository < Hanami::Repository
end

class AuthorRepository < Hanami::Repository
  associations do
    has_many :books
  end

  def create_with_books(data)
    assoc(:books).create(data)
  end

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
end

class OperatorRepository < Hanami::Repository
  self.relation = :t_operator

  mapping do
    attribute :id,   from: :operator_id
    attribute :name, from: :s_name
  end
end

class SourceFileRepository < Hanami::Repository
end

class WharehouseRepository < Hanami::Repository
end

class ProductRepository < Hanami::Repository
end

Hanami::Model.load!
