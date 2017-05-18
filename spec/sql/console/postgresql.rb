require 'hanami/model/sql/consoles/postgresql'

describe Hanami::Model::Sql::Consoles::Postgresql do
  let(:console) { Hanami::Model::Sql::Consoles::Postgresql.new(uri) }

  describe '#connection_string' do
    let(:uri) { URI.parse('postgres://username:password@localhost:1234/foo_development') }

    it 'returns a connection string' do
      expect(console.connection_string).to eq('psql -h localhost -d foo_development -p 1234 -U username')
    end

    it 'sets the PGPASSWORD environment variable' do
      console.connection_string
      expect(ENV['PGPASSWORD']).to eq('password')
      ENV.delete('PGPASSWORD')
    end
  end
end
