require 'hanami/model/sql/consoles/postgresql'

RSpec.shared_examples "sql_console_postgresql" do
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

    context 'when the password contains percent encoded characters' do
      let(:uri) { URI.parse('postgres://username:p%40ss@localhost:1234/foo_development') }

      it 'sets the PGPASSWORD environment variable decoding special characters' do
        console.connection_string
        expect(ENV['PGPASSWORD']).to eq('p@ss')
        ENV.delete('PGPASSWORD')
      end
    end

    context 'when components of the  hierarchical part of the URI can also be given as parameters' do
      let(:uri) { URI.parse('postgres:///foo_development?user=username&password=password&host=localhost&port=1234') }

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
end
