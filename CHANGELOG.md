# Lotus::Model
A persistence layer for Lotus

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
- [Stanislav Spiridonov] Ensure to require `'lotus/model/mapping/coercions'`
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
