require 'test_helper'
require_relative '../lib/hanami/model/migrator.rb'

describe Hanami::Model::Error do
  it 'inherits from ::StandardError' do
    Hanami::Model::Error.superclass.must_equal StandardError
  end

  it 'is parent to all custom exception' do
    Hanami::Model::NonPersistedEntityError.superclass.must_equal Hanami::Model::Error
    Hanami::Model::InvalidMappingError.superclass.must_equal Hanami::Model::Error
    Hanami::Model::InvalidCommandError.superclass.must_equal Hanami::Model::Error
    Hanami::Model::CheckConstraintViolationError.superclass.must_equal Hanami::Model::Error
    Hanami::Model::ForeignKeyConstraintViolationError.superclass.must_equal Hanami::Model::Error
    Hanami::Model::NotNullConstraintViolationError.superclass.must_equal Hanami::Model::Error
    Hanami::Model::UniqueConstraintViolationError.superclass.must_equal Hanami::Model::Error
    Hanami::Model::InvalidQueryError.superclass.must_equal Hanami::Model::Error
    Hanami::Model::Adapters::DatabaseAdapterNotFound.superclass.must_equal Hanami::Model::Error
    Hanami::Model::Adapters::NotSupportedError.superclass.must_equal Hanami::Model::Error
    Hanami::Model::Adapters::DisconnectedAdapterError.superclass.must_equal Hanami::Model::Error
    Hanami::Model::Adapters::NoAdapterError.superclass.must_equal Hanami::Model::Error
    Hanami::Model::Config::AdapterNotFound.superclass.must_equal Hanami::Model::Error
    Hanami::Model::NoMappingError.superclass.must_equal Hanami::Model::Error
    Hanami::Model::Mapping::UnmappedCollectionError.superclass.must_equal Hanami::Model::Error
    Hanami::Model::Mapping::EntityNotFound.superclass.must_equal Hanami::Model::Error
    Hanami::Model::Mapping::RepositoryNotFound.superclass.must_equal Hanami::Model::Error
    Hanami::Model::MigrationError.superclass.must_equal Hanami::Model::Error
  end
end
