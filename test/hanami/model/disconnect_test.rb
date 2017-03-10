require "test_helper"

# This test is tightly coupled to Sequel
#
# We should improve connection management via ROM
describe "Hanami::Model.disconnect" do
  before do
    # warm up
    connection[:users].to_a
  end

  let(:connection) { Hanami::Model.configuration.connection }

  it "disconnects from database" do
    # Sequel returns a collection of SQLite3::Database instances that were
    # active and has been disconnected from the database
    connections = Hanami::Model.disconnect
    connections.size.must_equal 1

    # If we don't hit the database, the next disconnection returns an empty set
    # of SQLite3::Database
    connections = Hanami::Model.disconnect
    connections.size.must_equal 0

    # If we try to use the database again, it's able to transparently reconnect
    connection[:users].to_a.must_be_kind_of(Array)

    # Now that we hit the database again, on this time the collection of
    # disconnected SQLite3::Database instances has size of 1
    connections = Hanami::Model.disconnect
    connections.size.must_equal 1
  end

  it "doesn't disconnect from the database when not connected yet" do
    Hanami::Model.configuration.stub(:connection, nil) do
      Hanami::Model.disconnect.must_equal nil
    end
  end
end
