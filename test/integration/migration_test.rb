require 'test_helper'
require 'lotus/model/migration'
require 'lotus/model/migrator'

describe 'SQL adapter migration' do
  let(:migrator) do
    Lotus::Model.configuration.reset!
    Lotus::Model.configure do
      migration_directory 'test/fixtures/migrations'
      adapter type: :sql, uri: SQLITE_CONNECTION_STRING
      logger ::Logger.new('/dev/null') # silence the output in test
    end

    Lotus::Model::Migrator.new
  end
  let(:db) { migrator.send(:db) }

  before do
    db.execute('DELETE FROM schema_migrations') if db.table_exists?(:schema_migrations)
    db.drop_table(:posts)    if db.table_exists?(:posts)
    db.drop_table(:comments) if db.table_exists?(:comments)
  end

  describe 'when there are migrations with duplicated versions' do
    it 'raises error' do
      Lotus::Model.configuration.migration_directory('test/fixtures/duplicated_migrations')
      expected = ["Duplicated versions in following migrations:"]
      expected << "  * test/fixtures/duplicated_migrations/20150222124516_create_comments.rb, test/fixtures/duplicated_migrations/20150222124516_remove_comments.rb"
      expected = expected.join("\n")
      exception = -> { Lotus::Model::Migrator.new }.must_raise(Lotus::Model::Migrator::DuplicatedVersionsError)
      exception.message.must_equal(expected)
    end
  end

  describe 'when there are missing migrations' do
    before do
      db[:schema_migrations].insert({
        :version => '20150122124514',
        :version => '20150222124515'
      })
    end

    it 'raises error when migrate' do
      exception = -> { migrator.migrate }.must_raise(Lotus::Model::Migrator::MissingMigrationsError)
      exception.message.must_equal "Applied migration files not in file system: test/fixtures/migrations/20150122124515_create_posts.rb, test/fixtures/migrations/20150222124516_create_comments.rb"
    end
  end

  describe 'when migrate to latest versions' do
    before do
      migrator.migrate
    end

    it 'applies all up migrations correctly' do
      db.table_exists?(:posts).must_equal true
      db.table_exists?(:comments).must_equal true
      db.from(:posts).columns.must_equal [:id, :title, :content]
      db.from(:comments).columns.must_equal [:id, :content]
      db.from(:schema_migrations).all.map { |row| row[:version] }.must_equal ['20150122124515', '20150222124516']
    end
  end

  describe 'when roll back to the previous migration' do
    before do
      migrator.migrate
      migrator.rollback
    end

    it 'applies all down migrations correctly' do
      db.table_exists?(:comments).must_equal false
      db.table_exists?(:posts).must_equal true

      db.from(:schema_migrations).all.map { |row| row[:version] }.must_equal ['20150122124515']
    end
  end

  describe 'when rolling back with specfied steps' do
    before do
      migrator.migrate
      migrator.rollback(step: 2)
    end

    it 'applies all down migrations correctly' do
      db.table_exists?(:comments).must_equal false
      db.table_exists?(:posts).must_equal false

      db.from(:schema_migrations).all.map { |row| row[:filename] }.must_equal []
    end
  end
end
