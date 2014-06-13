## v0.1.1
### Jun 23, 2014

99ea094 2014-06-13 **Luca Guidi** Introduced Lotus::Model::Mapping::Coercions in order to decouple from Lotus::Utils::Kernel

3fa2693 2014-05-10 **Luca Guidi** Support for Ruby 2.1.2

3682552 2014-04-25 **Peter Suschlik** Iterate over each value using `each_value`

cce7746 2014-04-24 **Peter Suschlik** Just extend the base class. No need to class_eval

719e03c 2014-04-24 **Peter Suschlik** Pass list of attributes to `attr_accessor`

## v0.1.0
### Apr 23, 2014

ec395d8 2014-04-22 **Luca Guidi** Added an accessor to introspect Mapper collections

96d9d00 2014-04-18 **Luca Guidi** Allow queries to be composed

a7d64c1 2014-04-18 **Damir Zekic**  Don't serialize identity column if it's nil

8484941 2014-04-17 **Luca Guidi** Fixed Sql::Collection#select for Ruby 2.0.0

bd9d679 2014-04-17 **Luca Guidi** Allow Sql#Query#order and #desc to accept multiple columns and/or multiple invokations.

b6a7af8 2014-04-16 **Luca Guidi** Enforce Adapter interface with #command and #query

3787f33 2014-04-16 **Luca Guidi** Allow Mapper to accept a custom coercer for the database

893109a 2014-04-15 **Luca Guidi** Ensure that unmapped attributes doens't interfer with initialization of entities

da37d7a 2014-04-15 **Luca Guidi** Implemented Memory::Query #to_s, #empty? and #any?

94f0ecb 2014-04-15 **Luca Guidi** Implemented Repository#exclude

6998328 2014-04-15 **Luca Guidi** Removed unused require

7211935 2014-04-15 **Luca Guidi** Implemented Sql::Query #to_s, #empty? and #any?

5e7e0c4 2014-04-15 **Luca Guidi** Implemented Sql::Query#negate!

5df30c2 2014-04-15 **Luca Guidi** Define top level constant ::Boolean

a9df2ec 2014-04-15 **Luca Guidi** Load Mapper when the framework is loaded

de21101 2014-04-15 **Luca Guidi** Extracted Mapping::Collection::REPOSITORY_SUFFIX constant

b4ed0fe 2014-04-15 **Luca Guidi** Expose Mapper#load! to make Lotus::Model thread safe

0936848 2014-04-14 **Luca Guidi** Moved UnmappedCollectionError under a separated file

b6e49ff 2014-04-14 **Luca Guidi** Removed serialization responsibility from Mapper

9057fbd 2014-04-14 **Luca Guidi** Removed unnecessary conditional in test

43c462f 2014-04-14 **Luca Guidi** Renamed Lotus::Model::Mapping::Collection#key into #identity

af59039 2014-04-14 **Luca Guidi** Removed serialization responsibility from Sql::Command

92101bb 2014-04-14 **Luca Guidi** Removed deserialization responsibility from Sql::Query

04e9597 2014-04-14 **Luca Guidi** Rewritten Sql::Command, it now works on scoped queries

eb49746 2014-04-14 **Luca Guidi** Coerce with the right type the primary key for Repository.find

daf3e04 2014-04-14 **Luca Guidi** Implemented Command for mutation actions such as insert, update, delete. Removed serialization responsibility to the adapter. Removed unused code.

5ae8b11 2014-04-13 **Luca Guidi** Sql and Memory adapter are now using Query to serve #all, #find, #first, #last

b0a35c5 2014-04-13 **Luca Guidi** Implemented Query#asc and #desc

ef2d1fa 2014-04-13 **Luca Guidi** Make querying thread safe for MemoryAdapter

db7e699 2014-04-12 **Luca Guidi** Implemented Query#select

2d83581 2014-04-12 **Luca Guidi** Implemented Query#exist?

13cfde0 2014-04-12 **Luca Guidi** Implemented Query#exclude

79596de 2014-04-12 **Luca Guidi** Implemented Query#range

70df238 2014-04-12 **Luca Guidi** Implemented Query#interval

a0cbb8c 2014-04-12 **Luca Guidi** Implemented Query#min

41e3d69 2014-04-12 **Luca Guidi** Implemented Query#max

5577283 2014-04-12 **Luca Guidi** Changed the semantic of Query#average: let return a float if needed, handle strings and nil values

3e1bddc 2014-04-12 **Luca Guidi** Implemented Query#sum

97d0fb9 2014-04-12 **Luca Guidi** Implemented Lotus::Model::Adapters::Memory::Query#average

d7068b5 2014-04-12 **Luca Guidi** Implemented Lotus::Model::Adapters::Sql::Query#average

21abc27 2014-04-10 **Luca Guidi** Introduced Sql::Query

7b63b7f 2014-04-10 **Luca Guidi** Implemented Memory::Query#count

517a89a 2014-04-10 **Luca Guidi** Make the results of Repository queries lazy

e6a756c 2014-04-10 **Luca Guidi** Renamed adapters with the "Adapter" suffix, in order to keep namespaces free.

8a076b9 2014-04-10 **Luca Guidi** Implemented Query#or, #limit and #offset

388957d 2014-04-09 **Luca Guidi** Added tests for SQL adapter and implemented #where, #and and #order for all the adapters

5a97c12 2014-04-09 **Luca Guidi** Initial design for quering the datasource

6f804db 2014-04-08 **Luca Guidi** Use Lotus::Utils::Kernel conversions

4ae6967 2014-04-07 **Luca Guidi** Allow the mapper to specify the primary key of a collection with Lotus::Model::Mapper::Collection#key.

85def40 2014-04-07 **Luca Guidi** Extracted Lotus::Model::Adapters::Memory::Collection::PrimaryKey

ff8d6d4 2014-04-07 **Luca Guidi** Lotus::Repository.collection is now configured by the framework internals.

122e040 2014-04-02 **Luca Guidi** Introduced attributes mapping and (de)serializations policies based on it.

f925ebc 2014-03-26 **Luca Guidi** Lotus::Entity#id is always the primary key

0bf8bb5 2014-03-26 **Luca Guidi** Introduced Lotus::Model::Adapters::Sql

cfbed99 2014-03-26 **Luca Guidi** Lotus::Model::Repository => Lotus::Repository

3a72d68 2014-03-26 **Luca Guidi** Lotus::Model::Entity => Lotus::Entity

ed29d2d 2014-03-26 **Luca Guidi** Preload Lotus::Model::Repository

f1bda7f 2014-03-26 **Luca Guidi** Improved tests and better semantic for Lotus::Model::Repository

65b8e1a 2014-03-26 **Luca Guidi** Tests and thready safety for Lotus::Model::Adapters::Memory

63d9fc5 2014-03-26 **Luca Guidi** When generate Entity#initialize use class attribute 'attributes', instead of the homonym argument

442987d 2014-02-17 **Luca Guidi** Lotus::Model::Repository.find raises a Lotus::Model::RecordNotFound exception if it can't find a record, associated with the given ID

c2b94e0 2014-02-15 **Luca Guidi** Ensure memory adapted is able to find a record for a string id

b258ea0 2014-02-07 **Luca Guidi** Make Repository to work with entities

0371b41 2014-02-05 **Luca Guidi** Implemented Entity

9d2bfe3 2014-02-05 **Luca Guidi** Renamed "object" in "entity" in method signatures. Repositories and adapters work on objects that are aware of the identity's concept.

be0e4e0 2014-02-05 **Luca Guidi** Extracted Abstract adapter and made Memory to inherit from it

3ca28af 2014-02-05 **Luca Guidi** Let Repository to delegate operations to the current adapter

3318bd1 2014-02-05 **Luca Guidi** Made Repository methods to accept one object instead of a collection

baf378a 2014-02-05 **Luca Guidi** Implemented Repository.delete

1b8c0a0 2014-02-05 **Luca Guidi** Implemented Repository.persist, .create and .update

c6bde87 2014-02-05 **Luca Guidi** Implemented Repository.find

a45248f 2014-02-05 **Luca Guidi** Initial mess
