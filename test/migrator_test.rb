require 'test_helper'
require 'hanami/model/migrator'

describe Hanami::Model::Migrator do
  load "test/migrator/#{ENV['HANAMI_DATABASE_TYPE']}.rb"
end
