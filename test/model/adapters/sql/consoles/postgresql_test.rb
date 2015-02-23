require 'test_helper'
require 'lotus/model/adapters/sql/consoles/postgresql'

describe Lotus::Model::Adapters::Sql::Consoles::Postgresql do
  let(:console) { Lotus::Model::Adapters::Sql::Consoles::Postgresql.new(uri) }

  describe '#connection_string' do
    describe 'with shell ok database uri' do
      let(:uri) { URI.parse('postgres://username:password@localhost:1234/foo_development') }

      it 'returns a connection string' do
        console.connection_string.must_equal 'psql -h localhost -d foo_development -p 1234 -U username'
      end

      it 'sets the PGPASSWORD environment variable' do
        console.connection_string
        ENV['PGPASSWORD'].must_equal 'password'
        ENV.delete('PGPASSWORD')
      end
    end

    describe 'with non shell ok database uri' do
      let(:uri) { URI.parse('postgres://username:password@localhost:1234/foo_development%20bar') }

      it 'returns an escaped connection string' do
        console.connection_string.must_equal 'psql -h localhost -d foo_development\\%20bar -p 1234 -U username'
      end
    end
  end
end
