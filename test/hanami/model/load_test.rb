require "test_helper"

describe "Hanami::Model.load!" do
  it "raises unknown database error when repository automapping spots an unknown type" do
    message = "Cannot find corresponding type for form"

    ROM.stub :container, ->(*) { raise ROM::SQL::UnknownDBTypeError, message } do
      exception = -> { Hanami::Model.load! }.must_raise(Hanami::Model::UnknownDatabaseTypeError)
      exception.message.must_equal message
    end
  end
end
