# frozen_string_literal: true

require "ostruct"

class BaseParams < OpenStruct
  def merge(other)
    other.merge(to_h)
  end
end

module Project
  module Entities
    class AccessToken < Hanami::Entity
    end

    class Author < Hanami::Entity
    end

    class Avatar < Hanami::Entity
    end

    class Book < Hanami::Entity
    end

    class BookOntology < Hanami::Entity
    end

    class Category < Hanami::Entity
    end

    class Color < Hanami::Entity
    end

    class Label < Hanami::Entity
    end

    class User < Hanami::Entity
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
    books.join(root).where(root[:id] => author.id).to_a
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
    author.join(root).where(root[:id] => book.id).one
  end

  def find_with_author(id)
    root.combine(:author).by_pk(id).one
  end

  def find_with_categories(id)
    root.combine(:categories).by_pk(id).one
  end

  def categories_for(book)
    categories.join(root).where(root[:id] => book.id).to_a
  end

  def add_category(book, *data)
    associated = categories.associations[:books].associate(data, book)
    command(:create, relation: book_ontologies).call(associated)
  end

  def clear_categories(book)
    book_ontologies.where(book_id: book.id).delete
  end
end

class BookOntologyRepository < Hanami::Repository[:book_ontologies]
  struct_namespace Project::Entities
end

class CategoryRepository < Hanami::Repository[:categories]
  struct_namespace Project::Entities

  def books_for(category)
    books.join(root).where(root[:id] => category.id).to_a
  end

  def on_sales_books_count(category)
    root.assoc(:books).where(root[:id] => category.id, on_sale: true).count
  end

  def books_count(category)
    books.join(root).where(root[:id] => category.id).count
  end

  def find_with_books(id)
    root.combine(:books).by_pk(id).one
  end

  def add_books(category, *data)
    # This is a bit weird. Is there any other way to do this?
    associated = books.associations[:categories].associate(data, category)
    command(:create, relation: book_ontologies).call(associated)
  end

  def remove_book(category, book_id)
    book_ontologies.where(category_id: category.id, book_id: book_id).delete
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
  #   def find_with_threads(id)
  #     users.combine(:threads).where(id: id).map_to(User).one
  #   end
  #
  #   def threads_for(user)
  #     assoc(:threads, user).to_a
  #   end
  #
  def find_with_avatar(id)
    root.combine(:avatar).by_pk(id).one
  end

  def create_with_avatar(data)
    command(:create, relation: root.combine(:avatar)).call(data)
  end

  def remove_avatar(user)
    avatars.where(user_id: user.id).delete
  end

  def add_avatar(user, data)
    # Should I use root.associations[:avatar].relation?
    # Is there a better way to do this?
    associated = root.associations[:avatar].associate(data, user)
    command(:create, relation: avatars).call(associated)
  end

  def update_avatar(user, data)
    associated = root.associations[:avatar].associate(data, user)
    command(:update, relation: avatars).call(associated)
  end

  def replace_avatar(user, data)
    transaction do
      remove_avatar(user)
      add_avatar(user, data)
    end
  end

  def avatar_for(user)
    avatars.join(root).where(root[:id] => user.id).one
  end
end

class Author < Hanami::OldEntity
end

# class Warehouse < Hanami::Entity
#   attribute :id,   Types::Integer
#   attribute :name, Types::String
#   attribute :code, Types::String.constrained(format: /\Awh\-/)
# end
#

class User < Hanami::OldEntity
end

class Account < Hanami::OldEntity
  attribute :id,         Types::Strict::Integer
  attribute :name,       Types::String
  attribute :codes,      Types::Collection(Types::Coercible::Integer)
  attribute :owner,      Types::Entity(User)
  attribute :users,      Types::Collection(User)
  attribute :email,      Types::String.constrained(format: /@/)
  attribute :created_at, Types::DateTime.constructor(->(dt) { ::DateTime.parse(dt.to_s) })
end


class PageVisit < Hanami::OldEntity
  attribute :id,        Types::Strict::Integer
  attribute :start,     Types::DateTime
  attribute :end,       Types::DateTime
  attribute :visitor,   Types::Hash
  attribute :page_info do
    attribute :name, Types::Coercible::String
    attribute :scroll_depth, Types::Coercible::Float
    attribute :meta, Types::Hash
  end
end

class Person < Hanami::OldEntity[:strict]
  attribute :id,   Types::Strict::Integer
  attribute :name, Types::Strict::String
end

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

Hanami::Model.configuration.load!
