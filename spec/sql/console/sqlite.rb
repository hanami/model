require 'hanami/model/sql/consoles/sqlite'

describe Hanami::Model::Sql::Consoles::Sqlite do
  let(:console) { Hanami::Model::Sql::Consoles::Sqlite.new(uri) }

  describe '#connection_string' do
    describe 'with shell ok database uri' do
      let(:uri) { URI.parse('sqlite://foo/bar.db') }
      it 'returns a connection string for Sqlite3' do
        expect(console.connection_string).to eq('sqlite3 foo/bar.db')
      end
    end

    describe 'with non shell ok database uri' do
      let(:uri) { URI.parse('sqlite://foo/%20bar.db') }
      it 'returns an escaped connection string for Sqlite3' do
        expect(console.connection_string).to eq('sqlite3 foo/\\%20bar.db')
      end
    end
  end
end
