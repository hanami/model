require 'test_helper'

describe Hanami::Model::Configuration do
  before do
    database_directory = Pathname.pwd.join('tmp', 'db')
    database_directory.join('migrations').mkpath
    FileUtils.touch database_directory.join('schema.sql')
  end

  let(:subject) { Hanami::Model::Configuration.new(configurator) }

  let(:configurator) do
    Hanami::Model::Configurator.build do
      adapter :sql, 'postgres://test.host/bookshelf'

      migrations 'tmp/db/migrations'
      schema     'tmp/db/schema.sql'
    end
  end

  describe '#url' do
    it 'equals to the configured url' do
      subject.url.must_equal 'postgres://test.host/bookshelf'
    end
  end

  describe '#connection' do
    it 'returns a raw connection aganist the database' do
      connection = subject.connection

      connection.must_be_kind_of Sequel::Database
      connection.url.must_equal 'postgres://test.host/bookshelf'
    end
  end

  describe '#gateway' do
    it 'returns default ROM gateway' do
      gateway = subject.gateway

      gateway.must_be_kind_of ROM::Gateway
      gateway.connection.must_equal subject.connection
    end
  end

  describe '#root' do
    it 'returns current directory' do
      subject.root.must_equal Pathname.pwd
    end
  end

  describe '#migrations' do
    it 'returns path to migrations' do
      expected = subject.root.join('tmp', 'db', 'migrations')

      subject.migrations.must_equal expected
    end
  end

  describe '#schema' do
    it 'returns path to database schema' do
      expected = subject.root.join('tmp', 'db', 'schema.sql')

      subject.schema.must_equal expected
    end
  end
end
