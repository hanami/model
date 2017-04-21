require 'test_helper'
require 'hanami/model/migrator'
require_relative "./migrator/#{Database.engine}.rb"

describe Hanami::Model::Migrator do
  include_examples "migrator_#{Database.engine}"
end
