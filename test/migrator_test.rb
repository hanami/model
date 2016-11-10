require 'test_helper'
require 'hanami/model/migrator'

describe Hanami::Model::Migrator do
  load "test/migrator/#{Database.engine}.rb"
end
