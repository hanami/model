require 'test_helper'

describe 'Hanami::Model.migration' do
  load "test/integration/migration/#{ENV['HANAMI_DATABASE_TYPE']}.rb"
end
