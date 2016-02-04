# Hanami::Model

A persistence framework for [Hanami](http://hanamirb.org).

It delivers a convenient public API to execute queries and commands against a database.
The architecture eases keeping the business logic (entities) separated from details such as persistence or validations.

It implements the following concepts:

  * [Entity](#entities) - An object defined by its identity.
  * [Repository](#repositories) - An object that mediates between the entities and the persistence layer.
  * [Data Mapper](#data-mapper) - A persistence mapper that keep entities independent from database details.
  * [Adapter](#adapter) – A database adapter.
  * [Query](#query) - An object that represents a database query.

Like all the other Hanami components, it can be used as a standalone framework or within a full Hanami application.

## Status

[![Gem Version](https://badge.fury.io/rb/hanami-model.svg)](http://badge.fury.io/rb/hanami-model)
[![Build Status](https://secure.travis-ci.org/hanami/model.svg?branch=master)](http://travis-ci.org/hanami/model?branch=master)
[![Coverage](https://coveralls.io/repos/github/hanami/model/badge.svg?branch=master)](https://coveralls.io/github/hanami/model?branch=master)
[![Code Climate](https://codeclimate.com/github/hanami/model/badges/gpa.svg)](https://codeclimate.com/github/hanami/model)
[![Dependencies](https://gemnasium.com/hanami/model.svg)](https://gemnasium.com/hanami/model)
[![Inline docs](http://inch-ci.org/github/hanami/model.png)](http://inch-ci.org/github/hanami/model)

## Contact

* Home page: http://hanamirb.org
* Mailing List: http://hanamirb.org/mailing-list
* API Doc: http://rdoc.info/gems/hanami-model
* Bugs/Issues: https://github.com/hanami/model/issues
* Support: http://stackoverflow.com/questions/tagged/hanami
* Chat: https://chat.hanamirb.org

## Rubies

__Hanami::Model__ supports Ruby (MRI) 2.2+ and JRuby 9000+

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hanami-model'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hanami-model

## Usage

This class provides a DSL to configure adapter, mapping and collection.

```ruby
require 'hanami/model'

class User
  include Hanami::Entity
  attributes :name, :age
end

class UserRepository
  include Hanami::Repository
end

Hanami::Model.configure do
  adapter type: :sql, uri: 'postgres://localhost/database'

  mapping do
    collection :users do
      entity      User
      repository UserRepository

      attribute :id,   Integer
      attribute :name, String
      attribute :age,  Integer
    end
  end
end

Hanami::Model.load!

user = User.new(name: 'Luca', age: 32)
user = UserRepository.create(user)

puts user.id # => 1

u = UserRepository.find(user.id)
u == user # => true
```

## Concepts

### Entities

An object that is defined by its identity.
See "Domain Driven Design" by Eric Evans.

An entity is the core of an application, where the part of the domain logic is implemented.
It's a small, cohesive object that expresses coherent and meaningful behaviors.

It deals with one and only one responsibility that is pertinent to the
domain of the application, without caring about details such as persistence
or validations.

This simplicity of design allows developers to focus on behaviors, or
message passing if you will, which is the quintessence of Object Oriented Programming.

```ruby
require 'hanami/model'

class Person
  include Hanami::Entity
  attributes :name, :age
end
```

When a class includes `Hanami::Entity` it receives the following interface:

  * `#id`
  * `#id=`
  * `#initialize(attributes = {})`

`Hanami::Entity` also provides the `.attributes` for defining attribute accessors for the given names.

If we expand the code above in **pure Ruby**, it would be:

```ruby
class Person
  attr_accessor :id, :name, :age

  def initialize(attributes = {})
    @id, @name, @age = attributes.values_at(:id, :name, :age)
  end
end
```

**Hanami::Model** ships `Hanami::Entity` for developers's convenience.

**Hanami::Model** depends on a narrow and well-defined interface for an Entity - `#id`, `#id=`, `#initialize(attributes={})`.
If your object implements that interface then that object can be used as an Entity in the **Hanami::Model** framework.

However, we suggest to implement this interface by including `Hanami::Entity`, in case that future versions of the framework will expand it.

See [Dependency Inversion Principle](http://en.wikipedia.org/wiki/Dependency_inversion_principle) for more on interfaces.

When a class extends a `Hanami::Entity` class, it will also *inherit* its mother's attributes.

```ruby
require 'hanami/model'

class Article
  include Hanami::Entity
  attributes :name
end

class RareArticle < Article
  attributes :price
end
```

That is, `RareArticle`'s attributes carry over `:name` attribute from `Article`,
thus is `:id, :name, :price`.

### Repositories

An object that mediates between entities and the persistence layer.
It offers a standardized API to query and execute commands on a database.

A repository is **storage independent**, all the queries and commands are
delegated to the current adapter.

This architecture has several advantages:

  * Applications depend on a standard API, instead of low level details
    (Dependency Inversion principle)

  * Applications depend on a stable API, that doesn't change if the
    storage changes

  * Developers can postpone storage decisions

  * Confines persistence logic at a low level

  * Multiple data sources can easily coexist in an application

When a class includes `Hanami::Repository`, it will receive the following interface:

  * `.persist(entity)` – Create or update an entity
  * `.create(entity)`  – Create a record for the given entity
  * `.update(entity)`  – Update the record corresponding to the given entity
  * `.delete(entity)`  – Delete the record corresponding to the given entity
  * `.all`   - Fetch all the entities from the collection
  * `.find`  - Fetch an entity from the collection by its ID
  * `.first` - Fetch the first entity from the collection
  * `.last`  - Fetch the last entity from the collection
  * `.clear` - Delete all the records from the collection
  * `.query` - Fabricates a query object

**A collection is a homogenous set of records.**
It corresponds to a table for a SQL database or to a MongoDB collection.

**All the queries are private**.
This decision forces developers to define intention revealing API, instead of leaking storage API details outside of a repository.

Look at the following code:

```ruby
ArticleRepository.where(author_id: 23).order(:published_at).limit(8)
```

This is **bad** for a variety of reasons:

  * The caller has an intimate knowledge of the internal mechanisms of the Repository.

  * The caller works on several levels of abstraction.

  * It doesn't express a clear intent, it's just a chain of methods.

  * The caller can't be easily tested in isolation.

  * If we change the storage, we are forced to change the code of the caller(s).

There is a better way:

```ruby
require 'hanami/model'

class ArticleRepository
  include Hanami::Repository

  def self.most_recent_by_author(author, limit = 8)
    query do
      where(author_id: author.id).
        order(:published_at)
    end.limit(limit)
  end
end
```

This is a **huge improvement**, because:

  * The caller doesn't know how the repository fetches the entities.

  * The caller works on a single level of abstraction. It doesn't even know about records, only works with entities.

  * It expresses a clear intent.

  * The caller can be easily tested in isolation. It's just a matter of stubbing this method.

  * If we change the storage, the callers aren't affected.

Here is an extended example of a repository that uses the SQL adapter.

```ruby
class ArticleRepository
  include Hanami::Repository

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
    rank.limit(1)
  end

  def self.comments_average
    query.average(:comments_count)
  end
end
```

You can also extract the common logic from your repository into a module to reuse it in other repositories. Here is a pagination example:

```ruby
module RepositoryHelpers
  module Pagination
    def paginate(limit: 10, offset: 0)
      query do
        limit(limit).offset(offset)
      end
    end
  end
end

class ArticleRepository
  include Hanami::Repository
  extend RepositoryHelpers::Pagination

  def self.published
    query do
      where(published: true)
    end
  end

  # other repository-specific methods here
end
```

That will allow `.paginate` usage on `ArticleRepository`, for example:
`ArticleRepository.published.paginate(15, 0)`

**Your models and repositories have to be in the same namespace.** Otherwise `Hanami::Model::Mapper#load!`
will not initialize your repositories correctly.

```ruby
class MyHanamiApp::Model::User
  include Hanami::Entity
  # your code here
end

# This repository will work...
class MyHanamiApp::Model::UserRepository
  include Hanami::Repository
  # your code here
end

# ...this will not!
class MyHanamiApp::Repository::UserRepository
  include Hanami::Repository
  # your code here
end
```

### Data Mapper

A persistence mapper that keeps entities independent from database details.
It is database independent, it can work with SQL, document, and even with key/value stores.

The role of a data mapper is to translate database columns into the corresponding attribute of an entity.

```ruby
require 'hanami/model'

mapper = Hanami::Model::Mapper.new do
  collection :users do
    entity User

    attribute :id,   Integer
    attribute :name, String
    attribute :age,  Integer
  end
end
```

For simplicity's sake, imagine that the mapper above is used with a SQL database.
We use `#collection` to indicate the name of the table that we want to map, `#entity` to indicate the class that we want to associate.
In the end, each call to `#attribute` associates the specified column with a corresponding Ruby type.

For advanced mapping and legacy databases, please have a look at the API doc.

**Known limitations**

Note there are limitations with inherited entities:

```ruby
require 'hanami/model'

class Article
  include Hanami::Entity
  attributes :name
end

class RareArticle < Article
  attributes :price
end

mapper = Hanami::Model::Mapper.new do
  collection :articles do
    entity Article

    attribute :id,    Integer
    attribute :name,  String
    attribute :price, Integer
  end
end
```

In the example above, there are a few problems:

* `Article` could not be fetched because mapping could not map `price`.
* Finding a persisted `RareArticle` record, for eg. `ArticleRepository.find(123)`,
the result is an `Article` not `RareArticle`.

### Adapter

An adapter is a concrete implementation of persistence logic for a specific database.
**Hanami::Model** is shipped with three adapters:

  * SqlAdapter
  * MemoryAdapter
  * FileSystemAdapter

An adapter can be associated with one or multiple repositories.

```ruby
require 'pg'
require 'hanami/model'
require 'hanami/model/adapters/sql_adapter'

mapper = Hanami::Model::Mapper.new do
  # ...
end

adapter = Hanami::Model::Adapters::SqlAdapter.new(mapper, 'postgres://host:port/database')

PersonRepository.adapter  = adapter
ArticleRepository.adapter = adapter
```

In the example above, we reuse the adapter because the target tables (`people` and `articles`) are defined in the same database.
**As rule of thumb, one adapter instance per database.**

### Query

An object that implements an interface for querying the database.
This interface may vary, according to the adapter's specifications.

Here is common interface for existing class:

  * `.all` - Resolves the query by fetching records from the database and translating them into entities
  * `.where`, `.and` - Adds a condition that behaves like SQL `WHERE`
  * `.or` - Adds a condition that behaves like SQL `OR`
  * `.exclude`, `.not` - Logical negation of a #where condition
  * `.select` - Selects only the specified columns
  * `.order`, `.asc` - Specify the ascending order of the records, sorted by the given columns
  * `.reverse_order`, `.desc` - Specify the descending order of the records, sorted by the given columns
  * `.limit` - Limit the number of records to return
  * `.offset` - Specify an `OFFSET` clause. Due to SQL syntax restriction, offset MUST be used with `#limit`
  * `.sum` - Returns the sum of the values for the given column
  * `.average`, `.avg` - Returns the average of the values for the given column
  * `.max` - Returns the maximum value for the given column
  * `.min` - Returns the minimum value for the given column
  * `.interval` - Returns the difference between the MAX and MIN for the given column
  * `.range` - Returns a range of values between the MAX and the MIN for the given column
  * `.exist?` - Checks if at least one record exists for the current conditions
  * `.count` - Returns a count of the records for the current conditions
  * `.join` - Adds an inner join with a table (only SQL)
  * `.left_join` - Adds a left join with a table (only SQL)

If you need more information regarding those methods, you can use comments from [memory](https://github.com/hanami/model/blob/master/lib/hanami/model/adapters/memory/query.rb#L29) or [sql](https://github.com/hanami/model/blob/master/lib/hanami/model/adapters/sql/query.rb#L28) adapters interface.

Think of an adapter for Redis, it will probably employ different strategies to filter records than an SQL query object.

### Model Error Coercions

All adapters' errors are encapsulated into Hanami error classes.

Hanami Model may raise the following exceptions:

  * `Hanami::Model::UniqueConstraintViolationError`
  * `Hanami::Model::ForeignKeyConstraintViolationError`
  * `Hanami::Model::NotNullConstraintViolationError`
  * `Hanami::Model::CheckConstraintViolationError`

For any other adapter's errors, Hanami will raise the `Hanami::Model::InvalidCommandError` object.
All errors contains the root cause and the full error message thrown by sql adapter.

### Conventions

  * A repository must be named after an entity, by appending `"Repository"` to the entity class name (eg. `Article` => `ArticleRepository`).

### Configurations

  * Non-standard repository can be configured for an entity, by setting `repository` on the collection.

  ```ruby
  require 'hanami/model'

  mapper = Hanami::Model::Mapper.new do
    collection :users do
      entity User
      repository EmployeeRepository
    end
  end
  ```

### Thread safety

**Hanami::Model**'s is thread safe during the runtime, but it isn't during the loading process.
The mapper compiles some code internally, be sure to safely load it before your application starts.

```ruby
Mutex.new.synchronize do
  Hanami::Model.load!
end
```

**This is not necessary, when Hanami::Model is used within a Hanami application.**

## Features

### Timestamps

If an entity has the following accessors: `:created_at` and `:updated_at`, they will be automatically updated when the entity is persisted.

```ruby
require 'hanami/model'

class User
  include Hanami::Entity
  attributes :name, :created_at, :updated_at
end

class UserRepository
  include Hanami::Repository
end

Hanami::Model.configure do
  adapter type: :memory, uri: 'memory://localhost/timestamps'

  mapping do
    collection :users do
      entity     User
      repository UserRepository

      attribute :id,         Integer
      attribute :name,       String
      attribute :created_at, DateTime
      attribute :updated_at, DateTime
    end
  end
end.load!

user = User.new(name: 'L')
puts user.created_at # => nil
puts user.updated_at # => nil

user = UserRepository.create(user)
puts user.created_at.to_s # => "2015-05-15T10:12:20+00:00"
puts user.updated_at.to_s # => "2015-05-15T10:12:20+00:00"

sleep 3
user.name = "Luca"
user      = UserRepository.update(user)
puts user.created_at.to_s # => "2015-05-15T10:12:20+00:00"
puts user.updated_at.to_s # => "2015-05-15T10:12:23+00:00"
```

### Dirty Tracking

Entities are able to track changes of their data, if `Hanami::Entity::DirtyTracking` is included.

```ruby
require 'hanami/model'

class User
  include Hanami::Entity
  include Hanami::Entity::DirtyTracking
  attributes :name, :age
end

class UserRepository
  include Hanami::Repository
end

Hanami::Model.configure do
  adapter type: :memory, uri: 'memory://localhost/dirty_tracking'

  mapping do
    collection :users do
      entity     User
      repository UserRepository

      attribute :id,   Integer
      attribute :name, String
      attribute :age,  String
    end
  end
end.load!

user = User.new(name: 'L')
user.changed? # => false

user.age = 33
user.changed?           # => true
user.changed_attributes # => {:age=>33}

user = UserRepository.create(user)
user.changed? # => false

user.update(name: 'Luca')
user.changed?           # => true
user.changed_attributes # => {:name=>"Luca"}

user = UserRepository.update(user)
user.changed? # => false

result = UserRepository.find(user.id)
result.changed? # => false
```

## Example

For a full working example, have a look at [EXAMPLE.md](https://github.com/hanami/model/blob/master/EXAMPLE.md).
Please remember that the setup code is only required for the standalone usage of **Hanami::Model**.
A **Hanami** application will handle that configurations for you.

## Versioning

__Hanami::Model__ uses [Semantic Versioning 2.0.0](http://semver.org)

## Contributing

1. Fork it ( https://github.com/hanami/model/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Copyright

Copyright © 2014-2016 Luca Guidi – Released under MIT License

This project was formerly known as Lotus (`lotus-model`).
