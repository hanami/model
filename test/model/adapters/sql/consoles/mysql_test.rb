require 'test_helper'
require 'lotus/model/adapters/sql/consoles/mysql'

describe Lotus::Model::Adapters::Sql::Consoles::Mysql do
  before do
    @uri = URI.parse('mysql://localhost/foo_development')
    @console = Lotus::Model::Adapters::Sql::Consoles::Mysql.new(@uri, options)
  end

  describe '#connection_string' do
    describe 'without options' do
      let(:options) { {} }
      it 'returns a connection string for mysql' do
        @console.connection_string.must_equal 'mysql -h localhost -D foo_development'
      end
    end

    describe 'with options' do
      let(:options) do
        {
          'database' => 'bar_development',
          'host' => 'foobar',
          'port' => '1234',
          'username' => 'lotus',
          'password' => 'password'
        }
      end
      it 'returns a connection string with all options' do
        @console.connection_string.must_equal 'mysql -h foobar -D bar_development -P 1234 -u lotus -p password'
      end
    end
  end
end

