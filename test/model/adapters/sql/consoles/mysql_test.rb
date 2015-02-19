require 'test_helper'
require 'lotus/model/adapters/sql/consoles/mysql'

describe Lotus::Model::Adapters::Sql::Consoles::Mysql do
  before do
    @uri = URI.parse('mysql://username:password@localhost:1234/foo_development')
    @console = Lotus::Model::Adapters::Sql::Consoles::Mysql.new(@uri)
  end

  describe '#connection_string' do
    it 'returns a connection string with all options' do
      @console.connection_string.must_equal 'mysql -h localhost -D foo_development -P 1234 -u username -p password'
    end
  end
end
