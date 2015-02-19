require 'test_helper'
require 'lotus/model/adapters/sql/consoles/postgresql'

describe Lotus::Model::Adapters::Sql::Consoles::Postgresql do
  before do
    @uri = URI.parse('postgres://username:password@localhost:1234/foo_development')
    @console = Lotus::Model::Adapters::Sql::Consoles::Postgresql.new(@uri)
  end

  describe '#connection_string' do
    it 'returns a connection string with all options' do
      @console.connection_string.must_equal 'psql -h localhost -d foo_development -p 1234 -U username'
    end

    it 'sets the PGPASSWORD environment variable' do
      @console.connection_string
      ENV['PGPASSWORD'].must_equal 'password'
    end
  end
end
