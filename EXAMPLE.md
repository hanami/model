# Lotus::Model

This is a guide that helps you to get started with [**Lotus::Model**](https://github.com/lotus/model).
You can find the full code source [here](https://gist.github.com/jodosha/11211048).

## Gems

First of all, we need to setup a `Gemfile`.

```ruby
source 'https://rubygems.org'

gem 'sqlite3'
gem 'lotus-model'
```

Then we can fetch the dependencies with `bundle install`.

## Setup

<a name="connection-url"></a>

**Lotus::Model** doesn't have migrations.
For this example we will use [Sequel](http://sequel.jeremyevans.net).
We create the database first.
Then we create two tables: `authors` and `articles`.

```ruby
require 'bundler/setup'
require 'sqlite3'
require 'lotus/model'
require 'lotus/model/adapters/sql_adapter'

connection_uri = "sqlite://#{ __dir__ }/test.db"

database = Sequel.connect(connection_uri)

database.create_table! :authors do
  primary_key :id
  String  :name
end

database.create_table! :articles do
  primary_key :id
  Integer :author_id,      null: false
  String  :title
  Integer :comments_count, default: 0
  Boolean :published,      default: false
end
```

## Entities

We have two entities in our application: `Author` and `Article`.
`Author` is a `Struct`, Lotus::Model can persist it.
`Article` has a small API concerning its publishing process.

```ruby
Author = Struct.new(:id, :name) do
  def initialize(attributes = {})
    @id, @name = attributes.values_at(:id, :name)
  end
end

class Article
  include Lotus::Entity
  self.attributes = :author_id, :title, :comments_count, :published # id is implicit

  def published?
    !!published
  end

  def publish!
    @published = true
  end
end
```

## Repositories

In order to persist and query the entities above, we define two corresponding repositories:

```ruby
class AuthorRepository
  include Lotus::Repository
end

class ArticleRepository
  include Lotus::Repository

  def self.most_recent_by_author(author, limit = 8)
    query do
      where(author_id: author.id).
        desc(:id).
        limit(limit)
    end
  end

  def self.most_recent_published_by_author(author, limit = 8)
    most_recent_by_author(author, limit).published
  end

  def self.published
    query do
      where(published: true)
    end
  end

  def self.drafts
    exclude published
  end

  def self.rank
    published.desc(:comments_count)
  end

  def self.best_article_ever
    rank.limit(1).first
  end

  def self.comments_average
    query.average(:comments_count)
  end
end
```

## Loading

```ruby
Lotus::Model.configure do
  adapter name: :application, type: :sql, uri: connection_uri

  mapping do
    collection :authors do
      entity     Author
      repository AuthorRepository

      attribute :id,   Integer
      attribute :name, String
    end

    collection :articles do
      entity     Article
      repository ArticleRepository

      attribute :id,             Integer
      attribute :author_id,      Integer
      attribute :title,          String
      attribute :comments_count, Integer
      attribute :published,      Boolean
    end
  end
end

Lotus::Model.load!
```

## Persist

We instantiate and persist an `Author` and a few `Articles` for our example:

```ruby
author = Author.new(name: 'Luca')
AuthorRepository.create(author)

articles = [
  Article.new(title: 'Announcing Lotus',              author_id: author.id, comments_count: 123, published: true),
  Article.new(title: 'Introducing Lotus::Router',     author_id: author.id, comments_count: 63,  published: true),
  Article.new(title: 'Introducing Lotus::Controller', author_id: author.id, comments_count: 82,  published: true),
  Article.new(title: 'Introducing Lotus::Model',      author_id: author.id)
]

articles.each do |article|
  ArticleRepository.create(article)
end
```

## Query

We use the repositories to query the database and return the entities we're looking for:

```ruby
ArticleRepository.first # => return the first article
ArticleRepository.last  # => return the last article

ArticleRepository.published # => return all the published articles
ArticleRepository.drafts    # => return all the drafts

ArticleRepository.rank      # => all the published articles, sorted by popularity

ArticleRepository.best_article_ever # => the most commented article

ArticleRepository.comments_average # => calculates the average of comments across all the published articles.

ArticleRepository.most_recent_by_author(author) # => most recent articles by an author (drafts and published).
ArticleRepository.most_recent_published_by_author(author) # => most recent published articles by an author
```

## Business Logic

As we've seen above, `Article` implements an API for publishing.
We use that logic to alter the state of an article (from draft to published).
We then use the repository to persist this new state.

```ruby
article = ArticleRepository.drafts.first

article.published? # => false
article.publish!

article.published? # => true

ArticleRepository.update(article)
```
