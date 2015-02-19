require 'test_helper'
require 'lotus/model/adapters/sql/consoles/sqlite'

describe Lotus::Model::Adapters::Sql::Consoles::Sqlite do
  before do
    @uri = URI.parse('sqlite://foo/bar.db')
    @console = Lotus::Model::Adapters::Sql::Consoles::Sqlite.new(@uri)
  end

  describe '#connection_string' do
    it 'returns a connection string for Sqlite3' do
      @console.connection_string.must_equal 'sqlite3 foo/bar.db'
    end
  end
end
