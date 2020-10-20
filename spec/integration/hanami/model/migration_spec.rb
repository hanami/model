require_relative "./migration/#{Database.engine}.rb"

RSpec.describe "Hanami::Model.migration" do
  include_examples "migration_integration_#{Database.engine}"
end
