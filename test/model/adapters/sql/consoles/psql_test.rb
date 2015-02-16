require 'test_helper'
require 'lotus/model/adapters/sql/consoles/psql'

describe Lotus::Model::Adapters::Sql::Consoles::Psql do
  before do
    @uri = URI.parse('postgres://username:password@localhost:1234/foo_development')
    @console = Lotus::Model::Adapters::Sql::Consoles::Psql.new(@uri, options)
  end

  describe '#connection_string' do
    describe 'without options' do
      let(:options) { {} }
      it 'returns a connection string for psql' do
        @console.connection_string.must_equal 'psql -h localhost -d foo_development -p 1234 -U username'
        ENV['PGPASSWORD'].must_equal 'password'
      end
    end

    describe 'with options' do
      let(:options) do
        {
          'database' => 'bar_development',
          'host' => 'foobar',
          'port' => '1234',
          'username' => 'lotus',
          'password' => 'p4ssword'
        }
      end
      it 'returns a connection string with all options' do
        @console.connection_string.must_equal 'psql -h foobar -d bar_development -p 1234 -U lotus'
      end

      it 'sets the PGPASSWORD environment variable' do
        @console.connection_string
        ENV['PGPASSWORD'].must_equal 'p4ssword'
      end
    end
  end
end
