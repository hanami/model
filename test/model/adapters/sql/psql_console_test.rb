require 'test_helper'

describe Lotus::Model::Adapters::Sql::PsqlConsole do
  before do
    @uri = URI.parse('postgres://localhost/foo_development')
    @console = Lotus::Model::Adapters::Sql::PsqlConsole.new(@uri, options)
  end

  describe '#connection_string' do
    describe 'without options' do
      let(:options) { {} }
      it 'returns a connection string for psql' do
        @console.connection_string.must_equal 'psql -h localhost -d foo_development'
      end
    end

    describe 'with options' do
      let(:options) do
        {
          'database' => 'bar_development',
          'host' => 'foobar',
          'port' => '1234',
          'username' => 'lotus',
          'password' => ''
        }
      end
      it 'returns a connection string with all options' do
        @console.connection_string.must_equal 'psql -h foobar -d bar_development -p 1234 -U lotus -W'
      end
    end
  end
end
