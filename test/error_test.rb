require 'test_helper'
require_relative '../lib/lotus/model/migrator.rb'

describe Lotus::Model::Error do
  it 'inherits from ::StandardError' do
    Lotus::Model::Error.superclass.must_equal StandardError
  end

  it 'is parent to all custom exception' do
    Lotus::Model::NonPersistedEntityError.superclass.must_equal Lotus::Model::Error
    Lotus::Model::InvalidMappingError.superclass.must_equal Lotus::Model::Error
    Lotus::Model::InvalidCommandError.superclass.must_equal Lotus::Model::Error
    Lotus::Model::InvalidQueryError.superclass.must_equal Lotus::Model::Error
    Lotus::Model::Adapters::DatabaseAdapterNotFound.superclass.must_equal Lotus::Model::Error
    Lotus::Model::Adapters::NotSupportedError.superclass.must_equal Lotus::Model::Error
    Lotus::Model::Adapters::DisconnectedAdapterError.superclass.must_equal Lotus::Model::Error
    Lotus::Model::Adapters::NoAdapterError.superclass.must_equal Lotus::Model::Error
    Lotus::Model::Config::AdapterNotFound.superclass.must_equal Lotus::Model::Error
    Lotus::Model::NoMappingError.superclass.must_equal Lotus::Model::Error
    Lotus::Model::Mapping::UnmappedCollectionError.superclass.must_equal Lotus::Model::Error
    Lotus::Model::Mapping::EntityNotFound.superclass.must_equal Lotus::Model::Error
    Lotus::Model::Mapping::RepositoryNotFound.superclass.must_equal Lotus::Model::Error
    Lotus::Model::MigrationError.superclass.must_equal Lotus::Model::Error
  end
end
