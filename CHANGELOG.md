# Hanami::Model
A persistence layer for Hanami

## v1.3.2 - 2019-01-31
### Fixed
- [Luca Guidi] Depend on `dry-logic` `~> 0.4.2`, `< 0.5`

## v1.3.1 - 2019-01-18
### Added
- [Luca Guidi] Official support for Ruby: MRI 2.6
- [Luca Guidi] Support `bundler` 2.0+

## v1.3.0 - 2018-10-24

## v1.3.0.beta1 - 2018-08-08
### Fixed
- [Luca Guidi] Print meaningful error message when connection URL is misconfigured (eg. `Unknown database adapter for URL: "". Please check your database configuration (hint: ENV['DATABASE_URL']).`)
- [Ian Ker-Seymer] Reliably parse query params from connection string

## v1.2.0 - 2018-04-11

## v1.2.0.rc2 - 2018-04-06

## v1.2.0.rc1 - 2018-03-30
### Fixed
- [Marcello Rocha & Luca Guidi] Ensure repository relations to access database attributes via `#[]` (eg. `projects[:name].ilike("Hanami")`)

## v1.2.0.beta2 - 2018-03-23

## v1.2.0.beta1 - 2018-02-28
### Added
- [Luca Guidi] Official support for Ruby: MRI 2.5
- [Marcello Rocha] Introduce `Hanami::Repository#command` as a factory for custom database commands. This is useful to create custom bulk operations.

## v1.1.0 - 2017-10-25
### Fixed
- [Luca Guidi] Ensure associations to always accept objects that are serializable into `::Hash`

## v1.1.0.rc1 - 2017-10-16
### Added
- [Marcello Rocha] Added support for associations aliasing via `:as` option (`has_many :users, through: :comments, as: :authors`)
- [Luca Guidi] Allow entities to be used as type in entities manual schema (`attribute :owner, Types::Entity(User)`)

## v1.1.0.beta3 - 2017-10-04

## v1.1.0.beta2 - 2017-10-03
### Added
- [Alfonso Uceda] Introduce `Hanami::Model::Migrator#rollback` to provide database migrations rollback
- [Alfonso Uceda] Improve connection string for PostgreSQL in order to pass credentials as URI query string

### Fixed
- [Marcello Rocha] One-To-Many properly destroy the associated methods

## v1.1.0.beta1 - 2017-08-11
### Added
- [Marcello Rocha] Many-To-One association (aka `belongs_to`)
- [Marcello Rocha] One-To-One association (aka `has_one`)
- [Marcello Rocha] Many-To-Many association (aka `has_many :through`)
- [Luca Guidi] Introduced new extra behaviors for entity manual schema: `:schema` (default), `:strict`, `:weak`, and `:permissive`

### Fixed
- [Sean Collins] Enhanced error message for Postgres `db create` and `db drop` when `createdb` and `dropdb` aren't in `PATH`

## v1.0.4 - 2017-10-14
### Fixed
- [Nikita Shilnikov] Keep the dependency on `rom-sql` at `~> 1.3`, which is compatible with `dry-types` `~> 0.11.0`
- [Nikita Shilnikov] Ensure to write Postgres JSON (`PGJSON`) type for nested associated records
- [Nikita Shilnikov] Ensure `Repository#select` to work with `Hanami::Model::MappedRelation`

## v1.0.3 - 2017-10-11
### Fixed
- [Luca Guidi] Keep the dependency on `dry-types` at `~> 0.11.0`

## v1.0.2 - 2017-08-04
### Fixed
- [Maurizio De Magnis] URI escape for Postgres password
- [Marion Duprey] Ensure repository to generate timestamps values even when only one between `created_at` and `updated_at` is present
- [Paweł Świątkowski] Make Postgres JSON(B) to work with Ruby arrays
- [Luca Guidi] Don't remove migrations when running `Hanami::Model::Migrator#apply` fails to dump the database

## v1.0.1 - 2017-06-23
### Fixed
- [Kai Kuchenbecker & Marcello Rocha & Luca Guidi] Ensure `Hanami::Entity#initialize` to not serialize (into `Hash`) other entities passed as an argument
- [Luca Guidi] Let `Hanami::Repository.relation=` to accept strings as an argument
- [Nikita Shilnikov] Prevent stack-overflow when `Hanami::Repository#update` is called thousand times

## v1.0.0 - 2017-04-06

## v1.0.0.rc1 - 2017-03-31

## v1.0.0.beta3 - 2017-03-17
### Added
- [Luca Guidi] Introduced `Hanami::Model.disconnect` to disconnect all the active database connections

## v1.0.0.beta2 - 2017-03-02
### Added
- [Semyon Pupkov] Allow to define Postgres connection URL as `"postgresql:///mydb?host=localhost&port=6433&user=postgres&password=testpasswd"`

### Fixed
- [Marcello Rocha] Fixed migrations MySQL detection of username and password
- [Luca Guidi] Fixed migrations creation/drop of a MySQL database with a dash in the name
- [Semyon Pupkov] Ensure `db console` to work when Postgres connection URL is defined with `"postgresql://"` scheme

## v1.0.0.beta1 - 2017-02-14
### Added
- [Luca Guidi] Official support for Ruby: MRI 2.4
- [Luca Guidi] Introduced `Repository#read` to fetch from database with raw SQL string
- [Luca Guidi] Introduced `Repository.schema` to manually configure the schema of a database table. This is useful for legacy databases where Hanami::Model autoinferring doesn't map correctly the schema.
- [Luca Guidi & Alfonso Uceda] Added `Hanami::Model::Configuration#gateway` to configure gateway and the raw connection
- [Luca Guidi] Added `Hanami::Model::Configuration#logger` to configure a logger
- [Luca Guidi] Database operations (including migrations) print informations to standard output

### Fixed
- [Thorbjørn Hermansen] Ensure repository to not override given timestamps
- [Luca Guidi] Raise `Hanami::Model::MissingPrimaryKeyError` if `Repository#find` is ran against a database w/o a primary key
- [Alfonso Uceda] Ensure SQLite databases to be used on JRuby when the database path is in the same directory of the Ruby script (eg. `./test.sqlite`)

### Changed
- [Luca Guidi] Automap the main relation in a repository, by removing the need of use `.as(:entity)`
- [Luca Guidi] Raise an `Hanami::Model::UnknownDatabaseTypeError` when the application is loaded and there is an unknown column type in the database

## v0.7.0 - 2016-11-15
### Added
- [Luca Guidi] `Hanami::Entity` defines an automatic schema for SQL databases
– [Luca Guidi] `Hanami::Entity` attributes schema
- [Luca Guidi] Experimental support for One-To-Many association (aka `has_many`)
- [Luca Guidi] Native support for PostgreSQL types like UUID, Array, JSON(B) and Money
- [Luca Guidi] Repositories instances can access all the relations (eg. `BookRepository` can access `users` relation via `#users`)
- [Luca Guidi] Automapping for SQL databases
- [Luca Guidi] Added `Hanami::Model::DatabaseError`

### Changed
- [Luca Guidi] Entities are immutable
- [Luca Guidi] Removed support for Memory and File System adapters
- [Luca Guidi] Removed support for _dirty tracking_
- [Luca Guidi] `Hanami::Entity.attributes` method no longer accepts a list of attributes, but a block to optionally define typed attributes
- [Luca Guidi] Removed `#fetch`, `#execute` and `#transaction` from repository
- [Luca Guidi] Removed `mapping` block from `Hanami::Model.configure`
- [Luca Guidi] Changed `adapter` signature in `Hanami::Model.configure` (use `adapter :sql, ENV['DATABASE_URL']`)
- [Luca Guidi] Repositories must inherit from `Hanami::Repository` instead of including it
- [Luca Guidi] Entities must inherit from `Hanami::Entity` instead of including it
- [Pascal Betz] Repositories use instance level interface (eg. `BookRepository.new.find` instead of `BookRepository.find`)
- [Luca Guidi] Repositories now accept hashes for CRUD operations
- [Luca Guidi] `Hanami::Repository#create` now accepts: hash (or entity)
- [Luca Guidi] `Hanami::Repository#update` now accepts two arguments: primary key (`id`) and data (or entity)
- [Luca Guidi] `Hanami::Repository#delete` now accepts: primary key (`id`)
- [Luca Guidi] Drop `Hanami::Model::NonPersistedEntityError`, `Hanami::Model::InvalidMappingError`, `Hanami::Model::InvalidCommandError`, `Hanami::Model::InvalidQueryError`
- [Luca Guidi] Official support for Ruby 2.3 and JRuby 9.0.5.0
- [Luca Guidi] Drop support for Ruby 2.0, 2.1, 2.2, and JRuby 9.0.0.0
- [Luca Guidi] Drop support for `mysql` gem in favor of `mysql2`

### Fixed
- [Luca Guidi] Ensure booleans to be correctly dumped in database
- [Luca Guidi] Ensure to respect default database schema values
- [Luca Guidi] Ensure SQL UPDATE to not override non-default primary key
- [James Hamilton] Print appropriate error message when trying to create a PostgreSQL database that is already existing

## v0.6.2 - 2016-06-01
### Changed
- [Kjell-Magne Øierud] Ensure inherited entities to expose attributes from base class

## v0.6.1 - 2016-02-05
### Changed
- [Hélio Costa e Silva & Pascal Betz] Mapping SQL Adapter's errors as `Hanami::Model` errors

## v0.6.1 - 2016-02-05
### Changed
- [Hélio Costa e Silva & Pascal Betz] Mapping SQL Adapter's errors as `Hanami::Model` errors

## v0.6.0 - 2016-01-22
### Changed
- [Luca Guidi] Renamed the project

## v0.5.2 - 2016-01-19
### Changed
- [Sean Collins] Improved error message for `Lotus::Model::Adapters::NoAdapterError`

### Fixed
- [Kyle Chong & Trung Lê] Catch Sequel exceptions and re-raise as `Lotus::Model::Error`

## v0.5.1 - 2016-01-12
### Added
- [Taylor Finnell] Let `Lotus::Model::Configuration#adapter` to accept arbitrary options (eg. `adapter type: :sql, uri: 'jdbc:...', after_connect: Proc.new { |connection| connection.auto_commit(true) }`)

### Changed
- [Andrey Deryabin] Improved `Entity#inspect`
- [Karim Tarek] Introduced `Lotus::Model::Error` and let all the framework exceptions to inherit from it.

### Fixed
- [Luca Guidi] Improved error message when trying to use a repository without mapping the corresponding collections
- [Sean Collins] Improved error message when trying to create database, but it fails (eg. missing `createdb` executable)
- [Andrey Deryabin] Improved error message when trying to drop database, but a client is still connected (useful for PostgreSQL)
- [Hiếu Nguyễn] Improved error message when trying to "prepare" database, but it fails

## v0.5.0 - 2015-09-30
### Added
- [Brenno Costa] Official support for JRuby 9k+
- [Luca Guidi] Command/Query separation via `Repository.execute` and `Repository.fetch`
- [Luca Guidi] Custom attribute coercers for data mapper
- [Alfonso Uceda] Added `#join` and `#left_join` and `#group` to SQL adapter

### Changed
- [Luca Guidi] `Repository.execute` no longer returns a result from the database.

### Fixed
- [Manuel Corrales] Use `dropdb` to drop PostgreSQL database.
- [Luca Guidi & Bohdan V.] Ignore dotfiles while running migrations.

## v0.4.1 - 2015-07-10
### Fixed
- [Nick Coyne] Fixed database creation for PostgreSQL (now it uses `createdb`).

## v0.4.0 - 2015-06-23
### Added
- [Luca Guidi] Database migrations

### Changed
- [Matthew Bellantoni] Made `Repository.execute` not callable from the outside (private Ruby method, public API).

## v0.3.2 - 2015-05-22
### Added
- [Dmitry Tymchuk & Luca Guidi] Fix for dirty tracking of attributes changed in place (eg. `book.tags << 'non-fiction'`)

## v0.3.1 - 2015-05-15
### Added
- [Dmitry Tymchuk] Dirty tracking for entities (via `Lotus::Entity::DirtyTracking` module to include)
- [My Mai] Automatic update of timestamps when an entity is persisted.
- [Peter Berkenbosch] Introduced `Lotus::Repository#execute`, to execute raw query/commands against database (eg. `BookRepository.execute "SELECT * FROM users"` or `BookRepository.execute "UPDATE users SET admin = 'f'"`)
- [Guilherme Franco] Memory and File System adapters now accept a block for `where`, `or`, `and` conditions (eg `where { age > 33 }`).

### Fixed
- [Luca Guidi] Ensure Array coercion to preserve original data structure

## v0.3.0 - 2015-03-23
### Added
- [Linus Pettersson] Database console

### Fixed
- [Alfonso Uceda Pompa] Don't send unwanted null values to the database, while coercing entities
- [Jan Lelis] Do not define top-level `Boolean`, because it is already defined by `hanami-utils`
- [Vsevolod Romashov] Fix entity class resolving in `Coercer#from_record`
- [Jason Harrelson] Add file and line to `instance_eval` in `Coercer` to make backtrace more usable

## v0.2.4 - 2015-02-20
### Fixed
- [Luca Guidi] When duplicate the framework don't copy over the original `Lotus::Model` configuration

## v0.2.3 - 2015-02-13
### Added
- [Alfonso Uceda Pompa] Added support for database transactions in repositories

### Fixed
- [Luca Guidi] Ensure file system adapter old data is read when a new process is started

## v0.2.2 - 2015-01-18
### Added
- [Luca Guidi] Coerce entities when persisted

## v0.2.1 - 2015-01-12
### Added
- [Luca Guidi] Compatibility between Lotus::Entity and Lotus::Validations

## v0.2.0 - 2014-12-23
### Added
- [Luca Guidi] Introduced file system adapter
– [Benny Klotz & Trung Lê] Introduced `Entity` inheritance of attributes
- [Trung Lê] Introduced `Entity#update` for bulk update of attributes
- [Luca Guidi] Improved error when try to use a repository which wasn't configured or when the framework wasn't loaded yet
- [Trung Lê] Introduced `Entity#to_h`
- [Trung Lê] Introduced `Lotus::Model.duplicate`
- [Trung Lê] Made `Lotus::Mapper` lazy
- [Trung Lê] Introduced thread safe autoloading for adapters
- [Felipe Sere] Add support for `Symbol` coercion
- [Celso Fernandes] Add support for `BigDecimal` coercion
- [Trung Lê] Introduced `Lotus::Model.load!` as entry point for loading
- [Trung Lê] Introduced `Mapper#repository` as DSL to associate a repository to a collection
- [Trung Lê & Tao Guo] Introduced `Configuration#mapping` as DSL to configure the mapping
- [Coen Wessels] Allow `where`, `exclude` and `or` to accept blocks
- [Trung Lê & Tao Guo] Introduced `Configuration#adapter` as DSL to configure the adapter
- [Trung Lê] Introduced `Lotus::Model::Configuration`

### Changed
- [Trung Lê] Changed `Entity.attributes=` to `Entity.attributes`
- [Trung Lê] In case of missing entity, let `Repository#find` returns `nil` instead of raise an exception

### Fixed
- [Rik Tonnard] Ensure correct behavior of `#offset` in memory adapter
- [Benny Klotz] Ensure `Entity` to set the attributes even when the given Hash uses strings as keys
- [Ben Askins] Always return the entity from `Repository#persist`
- [Jeremy Stephens] Made `Memory::Query#where` and `#or` behave more like the SQL counter-part

## v0.1.2 - 2014-06-26
### Fixed
- [Stanislav Spiridonov] Ensure to require `'hanami/model/mapping/coercions'`
- [Krzysztof Zalewski] `Entity` defines `#id` accessor by default


## v0.1.1 - 2014-06-23
### Added
- [Luca Guidi] Introduced `Lotus::Model::Mapping::Coercions` in order to decouple from `Lotus::Utils::Kernel`
- [Luca Guidi] Official support for Ruby 2.1

## v0.1.0 - 2014-04-23
### Added
- [Luca Guidi] Allow to inject coercer into mapper
- [Luca Guidi] Introduced database mapping
- [Luca Guidi] Introduced `Lotus::Entity`
- [Luca Guidi] Introduced SQL adapter
- [Luca Guidi] Introduced memory adapter
– [Luca Guidi] Introduced adapters for repositories
- [Luca Guidi] Introduced `Lotus::Repository`
