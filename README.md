# Lotus::Model

A persistence framework for [Lotus](http://lotusrb.org).

It delivers a convenient public API to execute queries and commands against a database.
The architecture allows to keep business logic (entities) separated from details such as persistence or validations.

It implements the following concepts:

  * [Entity](#entities) - An object defined by its identity.
  * [Repository](#repositories) - An object that mediates between the entities and the persistence layer.
  * [Data Mapper](#datamapper) - A persistence mapper that keep entities independent from database details.
  * [Adapter](#adapters) – A database adapter.
  * [Query](#queries) - An object that represents a database query.

Like all the other Lotus compontents, it can be used as a standalone framework or within a full Lotus application.

## Status

[![Gem Version](https://badge.fury.io/rb/lotus-model.png)](http://badge.fury.io/rb/lotus-model)
[![Build Status](https://secure.travis-ci.org/lotus/model.png?branch=master)](http://travis-ci.org/lotus/model?branch=master)
[![Coverage](https://coveralls.io/repos/lotus/model/badge.png?branch=master)](https://coveralls.io/r/lotus/model)
[![Code Climate](https://codeclimate.com/github/lotus/model.png)](https://codeclimate.com/github/lotus/model)
[![Dependencies](https://gemnasium.com/lotus/model.png)](https://gemnasium.com/lotus/model)
[![Inline docs](http://inch-pages.github.io/github/lotus/model.png)](http://inch-pages.github.io/github/lotus/model)

## Contact

* Home page: http://lotusrb.org
* Mailing List: http://lotusrb.org/mailing-list
* API Doc: http://rdoc.info/gems/lotus-model
* Bugs/Issues: https://github.com/lotus/model/issues
* Support: http://stackoverflow.com/questions/tagged/lotus-ruby
* Chat: https://gitter.im/lotus/chat

## Rubies

__Lotus::View__ supports Ruby (MRI) 2+

## Installation

Add this line to your application's Gemfile:

    gem 'lotus-model'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install lotus-model

## Usage

### Entities

  TODO expand

### Repositories

  TODO expand

### Data Mapper

  TODO expand

### Adapter

  TODO expand

### Query

  TODO expand

### Conventions

  * A repository must be named after an entity, by appeding `"Repository"` to the entity class name (eg. `Article` => `ArticleRepository`).

### Thread safety

**Lotus::Model**'s is thread safe during the runtime, but it isn't during the loading process.
The mapper compiles some code internally, be sure to safely load it before your application starts.

```ruby
Mutex.new.synchronize do
  mapper.load!
end
```

**This is not necessary, when Lotus::Model is used within a Lotus application.**

## Versioning

__Lotus::Model__ uses [Semantic Versioning 2.0.0](http://semver.org)

## Contributing

1. Fork it ( http://github.com/<my-github-username>/lotus-model/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Copyright

Copyright 2014 Luca Guidi – Released under MIT License
