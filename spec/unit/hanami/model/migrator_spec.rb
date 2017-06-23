require 'hanami/model/migrator'
require_relative "./migrator/#{Database.engine}"

RSpec.describe Hanami::Model::Migrator do
  include_examples "migrator_#{Database.engine}"
end
