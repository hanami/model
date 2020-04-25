# frozen_string_literal: true

require "ostruct"

class BaseParams < OpenStruct
  def merge(other)
    other.merge(to_h)
  end
end

module Hanami
  class Entity2 < ROM::Struct
    # def id
    #   attributes.fetch(:id, nil)
    # end

    def hash
      [self.class, id].hash
    end

    def ==(other)
      self.class.to_s == other.class.to_s &&
        id == other.id
    end
  end
end

module Project
  module Entities
    class AccessToken < Hanami::Entity2
    end

    class Author < Hanami::Entity2
    end

    class Avatar < Hanami::Entity2
    end

    class Book < Hanami::Entity2
    end

    class Color < Hanami::Entity2
    end

    class Label < Hanami::Entity2
    end

    class User < Hanami::Entity2
    end
  end
end

class AccessTokenRepository < Hanami::Repository[:tokens]
  struct_namespace Project::Entities
end

class AuthorRepository < Hanami::Repository[:authors]
  struct_namespace Project::Entities

  def find_with_books(id)
    root.combine(:books).by_pk(id).one
  end

  # There must be a better way to do this - MRP - 2020-04-25
  def books_for(author)
    root.assoc(:books).where(root[:id] => author.id).map_to(Project::Entities::Book).to_a
  end

  def books_count(author)
    root.assoc(:books).where(root[:id] => author.id).count
  end

  def on_sales_books_count(author)
    root.assoc(:books).where(root[:id] => author.id, on_sale: true).count
  end

  def add_book(author, data)
    associated = root.associations[:books].associate(data, author)
    command(:create, relation: books).call(associated)
  end

  def create_with_books(data)
    command(:create, relation: root.combine(:books)).call(data)
  end

  # There's no simple way to delete from the has_many association it seems.
  # One could argue that this is better done directly on the BookRepository
  # and that we are only mirroring AR behaviour. - MRP - 2020-04-25
  def delete_books(author)
    books.where(author_id: author.id).delete
  end

  def delete_on_sales_books(author)
    books.where(author_id: author.id, on_sale: true).delete
  end

  def remove_book(_author, id)
    command(:update, relation: books).by_pk(id).call(author_id: nil)
  end

  #   def find_book(author, id)
  #     book_for(author, id).one
  #   end
  #
  #   def book_exists?(author, id)
  #     book_for(author, id).exists?
  #   end
end

class AvatarRepository < Hanami::Repository[:avatars]
  struct_namespace Project::Entities

  def by_user(id)
    root.where(user_id: id).to_a
  end
end

class BookRepository < Hanami::Repository[:books]
  struct_namespace Project::Entities

  def author_for(book)
    root.by_pk(book.id).combine(:author).one.author
  end

  def find_with_author(id)
    books.combine(:author).by_pk(id).one
  end
end

class ColorRepository < Hanami::Repository[:colors]
  struct_namespace Project::Entities
end

class LabelRepository < Hanami::Repository[:labels]
  struct_namespace Project::Entities
end

class UserRepository < Hanami::Repository[:users]
  struct_namespace Project::Entities

  def by_name(name)
    root.where(name: name)
  end

  def by_matching_name(name)
    root.where(users[:name].ilike(name)).to_a
  end

  def by_name_with_root(name)
    root.where(name: name)
  end

  def find_all_by_manual_query
    users.read("select * from users").map_to(Project::Entities::User).to_a
  end

  def ids
    root.select(:id).to_a
  end

  def select_id_and_name
    root.select(:id, :name).to_a
  end

  #   associations do
  #     has_one :avatar
  #     has_many :posts, as: :threads
  #     has_many :comments
  #   end
  #
  #   def find_with_threads(id)
  #     users.combine(:threads).where(id: id).map_to(User).one
  #   end
  #
  #   def threads_for(user)
  #     assoc(:threads, user).to_a
  #   end
  #
  #   def find_with_avatar(id)
  #     users.combine(:avatar).where(id: id).map_to(User).one
  #   end
  #
  #   def create_with_avatar(data)
  #     assoc(:avatar).create(data)
  #   end
  #
  #   def remove_avatar(user)
  #     assoc(:avatar, user).delete
  #   end
  #
  #   def add_avatar(user, data)
  #     assoc(:avatar, user).add(data)
  #   end
  #
  #   def update_avatar(user, data)
  #     assoc(:avatar, user).update(data)
  #   end
  #
  #   def replace_avatar(user, data)
  #     assoc(:avatar, user).replace(data)
  #   end
  #
  #   def avatar_for(user)
  #     assoc(:avatar, user).one
  #   end
end

# class Avatar < Hanami::Entity
# end
#
# class Author < Hanami::Entity
# end
#
# class Book < Hanami::Entity
# end
#
# class Category < Hanami::Entity
# end
#
# class BookOntology < Hanami::Entity
# end
#
# class Operator < Hanami::Entity
# end

# class SourceFile < Hanami::Entity
# end
#
# class Post < Hanami::Entity
# end
#
# class Comment < Hanami::Entity
# end
#
# class Warehouse < Hanami::Entity
#   attribute :id,   Types::Integer
#   attribute :name, Types::String
#   attribute :code, Types::String.constrained(format: /\Awh\-/)
# end
#
# class Account < Hanami::Entity
#   attribute :id,         Types::Strict::Integer
#   attribute :name,       Types::String
#   attribute :codes,      Types::Collection(Types::Coercible::Integer)
#   attribute :owner,      Types::Entity(User)
#   attribute :users,      Types::Collection(User)
#   attribute :email,      Types::String.constrained(format: /@/)
#   attribute :created_at, Types::DateTime.constructor(->(dt) { ::DateTime.parse(dt.to_s) })
# end
#
# class PageVisit < Hanami::Entity
#   attribute :id,        Types::Strict::Integer
#   attribute :start,     Types::DateTime
#   attribute :end,       Types::DateTime
#   attribute :visitor,   Types::Hash
#   attribute :page_info do
#     attribute :name, Types::Coercible::String
#     attribute :scroll_depth, Types::Coercible::Float
#     attribute :meta, Types::Hash
#   end
# end
#
# class Person < Hanami::Entity[:strict]
#   attribute :id,   Types::Strict::Integer
#   attribute :name, Types::Strict::String
# end

# class Product < Hanami::Entity
# end

# class Color < Hanami::Entity
# end

# class PostRepository < Hanami::Repository[:posts]
#   associations do
#     belongs_to :user, as: :author
#     has_many :comments
#     has_many :users, through: :comments, as: :commenters
#   end
#
#   def find_with_commenters(id)
#     combine(:commenters).where(id: id).map_to(Post).to_a
#   end
#
#   def commenters_for(post)
#     assoc(:commenters, post).to_a
#   end
#
#   def find_with_author(id)
#     posts.combine(:author).where(id: id).map_to(Post).one
#   end
#
#   def feed_for(id)
#     posts.combine(:author, comments: :user).where(id: id).map_to(Post).one
#   end
#
#   def author_for(post)
#     assoc(:author, post).one
#   end
# end
#
# class CommentRepository < Hanami::Repository[:comments]
#   associations do
#     belongs_to :post
#     belongs_to :user
#   end
#
#   def commenter_for(comment)
#     assoc(:user, comment).one
#   end
# end
#

#
# class AuthorRepository < Hanami::Repository[:authors]
#   associations do
#     has_many :books
#   end
#
#   def create_many(data, opts: {})
#     command(:create, result: :many, **opts).call(data)
#   end
#
#   def create_with_books(data)
#     assoc(:books).create(data)
#   end
#
#   def find_with_books(id)
#     authors.combine(:books).by_pk(id).map_to(Author).one
#   end
#
#   def books_for(author)
#     assoc(:books, author)
#   end
#
#   def add_book(author, data)
#     assoc(:books, author).add(data)
#   end
#
#   def remove_book(author, id)
#     assoc(:books, author).remove(id)
#   end
#
#   def delete_books(author)
#     assoc(:books, author).delete
#   end
#
#   def delete_on_sales_books(author)
#     assoc(:books, author).where(on_sale: true).delete
#   end
#
#   def books_count(author)
#     assoc(:books, author).count
#   end
#
#   def on_sales_books_count(author)
#     assoc(:books, author).where(on_sale: true).count
#   end
#
#   def find_book(author, id)
#     book_for(author, id).one
#   end
#
#   def book_exists?(author, id)
#     book_for(author, id).exists?
#   end
#
#   private
#
#   def book_for(author, id)
#     assoc(:books, author).where(id: id)
#   end
# end
#
# class BookOntologyRepository < Hanami::Repository[:book_ontologies]
#   associations do
#     belongs_to :books
#     belongs_to :categories
#   end
# end
#
# class CategoryRepository < Hanami::Repository[:categories]
#   associations do
#     has_many :books, through: :book_ontologies
#   end
#
#   def books_for(category)
#     assoc(:books, category)
#   end
#
#   def on_sales_books_count(category)
#     assoc(:books, category).where(on_sale: true).count
#   end
#
#   def books_count(category)
#     assoc(:books, category).count
#   end
#
#   def find_with_books(id)
#     categories.combine(:books).where(id: id).map_to(Category).one
#   end
#
#   def add_books(category, *books)
#     assoc(:books, category).add(*books)
#   end
#
#   def remove_book(category, book_id)
#     assoc(:books, category).remove(book_id)
#   end
# end
#
# class BookRepository < Hanami::Repository[:books]
#   associations do
#     belongs_to :author
#     has_many :categories, through: :book_ontologies
#   end
#
#   def add_category(book, category)
#     assoc(:categories, book).add(category)
#   end
#
#   def clear_categories(book)
#     assoc(:categories, book).delete
#   end
#
#   def categories_for(book)
#     assoc(:categories, book).to_a
#   end
#
#   def find_with_categories(id)
#     books.combine(:categories).where(id: id).map_to(Book).one
#   end
#
#   def find_with_author(id)
#     books.combine(:author).where(id: id).map_to(Book).one
#   end
#
#   def author_for(book)
#     assoc(:author, book).one
#   end
# end
#
# class OperatorRepository < Hanami::Repository[:t_operator]
#   mapping do
#     attribute :id,   from: :operator_id
#     attribute :name, from: :s_name
#   end
# end

# class SourceFileRepository < Hanami::Repository[:source_files]
# end
#
# class WarehouseRepository < Hanami::Repository[:warehouses]
# end

# class ProductRepository < Hanami::Repository[:products]
# end

Hanami::Model.configuration.load!([]) # Hanami::Model.repositories)
