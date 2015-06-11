require 'test_helper'
require 'lotus/model/migrator'

describe Lotus::Model::Migrator do
  describe '#initialize' do
    describe 'when adapter is not SQL' do
      it 'raises error' do
        Lotus::Model.configuration.reset!
        Lotus::Model.configure do
          adapter type: :memory, uri: nil
          logger ::Logger.new('/dev/null')
        end
        exception = -> { Lotus::Model::Migrator.new }.must_raise Lotus::Model::Migrator::UnsupportedAdapterError
        exception.message.must_equal 'Adapter memory is not supported'
      end
    end

    describe 'when adapter is configured' do
      it 'raises error' do
        Lotus::Model.configuration.reset!
        exception = -> { Lotus::Model::Migrator.new }.must_raise Lotus::Model::Migrator::MissingAdapterConfigurationError
        exception.message.must_equal 'Please configure your adapter. See Lotus::Model.configure for more details'
      end
    end
  end

  describe '#current_version' do
    let(:migrator) do
      Lotus::Model.configuration.reset!
      Lotus::Model.configure do
        migrations_directory 'test/fixtures/migrations'
        adapter type: :sql, uri: SQLITE_CONNECTION_STRING
        logger ::Logger.new('/dev/null')
      end
      Lotus::Model::Migrator.new
    end

    let(:db) { migrator.send(:db) }

    before do
      db.execute('DELETE FROM schema_migrations') if db.table_exists?(:schema_migrations)
    end

    describe 'when there is no records in schema_migrations table' do
      it 'returns 0' do
        migrator.current_version.must_equal 0
      end
    end

    describe 'when there are records in schema_migrations table' do
      before do
        db[:schema_migrations].insert({
          :version => '20150122124515',
          :version => '20150222124516'
        })
      end

      it 'returns the latest version ordered by filename version' do
        migrator.current_version.must_equal 20150222124516
      end
    end
  end

end
