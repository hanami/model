require 'test_helper'

describe 'Hanami::Model.migration' do
  load "test/integration/migration/#{Database.engine}.rb"
end
