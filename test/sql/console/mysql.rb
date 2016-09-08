require 'test_helper'
require 'hanami/model/sql/consoles/mysql'

describe Hanami::Model::Sql::Consoles::Mysql do
  let(:console) { Hanami::Model::Sql::Consoles::Mysql.new(uri) }

  describe '#connection_string' do
    let(:uri) { URI.parse('mysql://username:password@localhost:1234/foo_development') }

    it 'returns a connection string' do
      console.connection_string.must_equal 'mysql -h localhost -D foo_development -P 1234 -u username -p password'
    end
  end
end
