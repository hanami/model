# Hanami::Model

A persistence framework for [Hanami](http://hanamirb.org).

It delivers a convenient public API to execute queries and commands against a database.
The architecture eases keeping the business logic (entities) separated from details such as persistence or validations.

It implements the following concepts:

  * [Entity](#entities) - A model domain object defined by its identity.
  * [Repository](#repositories) - An object that mediates between the entities and the persistence layer.

Like all the other Hanami components, it can be used as a standalone framework or within a full Hanami application.

## Version

**This branch contains the code for `hanami-model` 2.x.**

## Status

[![Gem Version](https://badge.fury.io/rb/hanami-model.svg)](https://badge.fury.io/rb/hanami-model)
[![CI](https://github.com/hanami/model/workflows/ci/badge.svg?branch=main)](https://github.com/hanami/model/actions?query=workflow%3Aci+branch%3Amain)
[![Test Coverage](https://codecov.io/gh/hanami/model/branch/main/graph/badge.svg)](https://codecov.io/gh/hanami/model)
[![Depfu](https://badges.depfu.com/badges/3a5d3f9e72895493bb6f39402ac4f129/overview.svg)](https://depfu.com/github/hanami/model?project=Bundler)
[![Inline Docs](http://inch-ci.org/github/hanami/model.svg)](http://inch-ci.org/github/hanami/model)

## Contact

* Home page: http://hanamirb.org
* Mailing List: http://hanamirb.org/mailing-list
* API Doc: http://rdoc.info/gems/hanami-model
* Bugs/Issues: https://github.com/hanami/model/issues
* Support: http://stackoverflow.com/questions/tagged/hanami
* Chat: https://chat.hanamirb.org

## Rubies

__Hanami::Model__ supports Ruby (MRI) 2.6+

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

This class provides a DSL to configure the connection.

```ruby
require 'hanami/model'
require 'hanami/model/sql'

class User < Hanami::Entity
end

class UserRepository < Hanami::Repository
end

Hanami::Model.configure do
  adapter :sql, 'postgres://username:password@localhost/bookshelf'
end.load!

repository = UserRepository.new
user       = repository.create(name: 'Luca')

puts user.id # => 1

found = repository.find(user.id)
found == user # => true

updated = repository.update(user.id, age: 34)
updated.age # => 34

repository.delete(user.id)
```

## Concepts

### Entities

A model domain object that is defined by its identity.
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

class Person < Hanami::Entity
end
```

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

When a class inherits from `Hanami::Repository`, it will receive the following interface:

  * `#create(data)`     – Create a record for the given data (or entity)
  * `#update(id, data)` – Update the record corresponding to the given id by setting the given data (or entity)
  * `#delete(id)`       – Delete the record corresponding to the given id
  * `#all`              - Fetch all the entities from the relation
  * `#find`             - Fetch an entity from the relation by primary key
  * `#first`            - Fetch the first entity from the relation
  * `#last`             - Fetch the last entity from the relation
  * `#clear`            - Delete all the records from the relation

**A relation is a homogenous set of records.**
It corresponds to a table for a SQL database or to a MongoDB collection.

**All the queries are private**.
This decision forces developers to define intention revealing API, instead of leaking storage API details outside of a repository.

Look at the following code:

```ruby
ArticleRepository.new.where(author_id: 23).order(:published_at).limit(8)
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

class ArticleRepository < Hanami::Repository
  def most_recent_by_author(author, limit: 8)
    articles.where(author_id: author.id).
      order(:published_at).
      limit(limit)
  end
end
```

This is a **huge improvement**, because:

  * The caller doesn't know how the repository fetches the entities.

  * The caller works on a single level of abstraction. It doesn't even know about records, only works with entities.

  * It expresses a clear intent.

  * The caller can be easily tested in isolation. It's just a matter of stubbing this method.

  * If we change the storage, the callers aren't affected.

### Mapping

Hanami::Model can **_automap_** columns from relations and entities attributes.

When using a `sql` adapter, you must require `hanami/model/sql` before `Hanami::Model.load!` is called so the relations are loaded correctly.

However, there are cases where columns and attribute names do not match (mainly **legacy databases**).

```ruby
require 'hanami/model'

class UserRepository < Hanami::Repository
  self.relation = :t_user_archive

  mapping do
    attribute :id,   from: :i_user_id
    attribute :name, from: :s_name
    attribute :age,  from: :i_age
  end
end
```
**NOTE:** This feature should be used only when **_automapping_** fails because of the naming mismatch.

### Conventions

  * A repository must be named after an entity, by appending `"Repository"` to the entity class name (eg. `Article` => `ArticleRepository`).

### Thread safety

**Hanami::Model**'s is thread safe during the runtime, but it isn't during the loading process.
The mapper compiles some code internally, so be sure to safely load it before your application starts.

```ruby
Mutex.new.synchronize do
  Hanami::Model.load!
end
```

**This is not necessary when Hanami::Model is used within a Hanami application.**

## Features

### Timestamps

If an entity has the following accessors: `:created_at` and `:updated_at`, they will be automatically updated when the entity is persisted.

```ruby
require 'hanami/model'
require 'hanami/model/sql'

class User < Hanami::Entity
end

class UserRepository < Hanami::Repository
end

Hanami::Model.configure do
  adapter :sql, 'postgresql://localhost/bookshelf'
end.load!

repository = UserRepository.new

user = repository.create(name: 'Luca')

puts user.created_at.to_s # => "2016-09-19 13:40:13 UTC"
puts user.updated_at.to_s # => "2016-09-19 13:40:13 UTC"

sleep 3
user = repository.update(user.id, age: 34)
puts user.created_at.to_s # => "2016-09-19 13:40:13 UTC"
puts user.updated_at.to_s # => "2016-09-19 13:40:16 UTC"
```

## Configuration

### Logging

In order to log database operations, you can configure a logger:

```ruby
Hanami::Model.configure do
  # ...
  logger "log/development.log", level: :debug
end
```

It accepts the following arguments:

  * `stream`: a Ruby StringIO object - it can be `$stdout` or a path to file (eg. `"log/development.log"`) - Defaults to `$stdout`
  * `:level`: logging level - it can be: `:debug`, `:info`, `:warn`, `:error`, `:fatal`, `:unknown` - Defaults to `:debug`
  * `:formatter`: logging formatter - it can be: `:default` or `:json` - Defaults to `:default`

## Versioning

__Hanami::Model__ uses [Semantic Versioning 2.0.0](http://semver.org)

## Contributing

1. Fork it ( https://github.com/hanami/model/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Copyright

Copyright © 2014-2021 Luca Guidi – Released under MIT License

This project was formerly known as Lotus (`lotus-model`).
