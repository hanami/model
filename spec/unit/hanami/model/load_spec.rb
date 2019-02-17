# frozen_string_literal: true

RSpec.describe "Hanami::Model.configuration.load!" do
  let(:message) { "Cannot find corresponding type for form" }

  before do
    allow(ROM).to receive(:container) { raise ROM::SQL::UnknownDBTypeError, message }
  end

  it "raises unknown database error when repository automapping spots an unknown type" do
    expect { Hanami::Model.configuration.load!(Hanami::Model.repositories) }.to raise_error(Hanami::Model::UnknownDatabaseTypeError, message)
  end
end
