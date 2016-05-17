require 'test_helper'
require 'hanami/model/migrator'

describe 'Memory Database Migration' do
  let(:adapter_prefix) { 'jdbc:' if Hanami::Utils.jruby?  }

  # Unfornatelly we need to explicitly include `::memory:` for JDBC
  # https://github.com/jeremyevans/sequel/blob/master/lib/sequel/adapters/jdbc/sqlite.rb#L61
  #
  let(:adapter_sufix)  { Hanami::Utils.jruby? ? ':memory:' : '/' }

  before do
    Hanami::Model.unload!
  end

  after do
    Hanami::Model::Migrator.drop rescue nil
    Hanami::Model.unload!
  end

  describe 'SQLite In Memory' do
    before do
      @uri = uri = "#{ adapter_prefix }sqlite:#{ adapter_sufix }"

      Hanami::Model.configure do
        adapter type: :sql, uri: uri
        migrations __dir__ + '/../../fixtures/migrations'
      end
    end

    after(:each) do
      SQLite3::Database.new(@uri) { |db| db.close } if File.exist?(@uri)
    end

    describe "create" do
      it "does nothing" do
        Hanami::Model::Migrator.create

        connection = Sequel.connect(@uri)
        connection.tables.must_be :empty?
      end
    end

    describe "drop" do
      before do
        Hanami::Model::Migrator.create
      end

      it "does nothing" do
        Hanami::Model::Migrator.drop

        connection = Sequel.connect(@uri)
        connection.tables.must_be :empty?
      end
    end

    describe "migrate" do
      before do
        Hanami::Model::Migrator.create
      end

      describe "when no migrations" do
        before do
          @migrations_root = migrations_root = Pathname.new(__dir__ + '/../../fixtures/empty_migrations')

          Hanami::Model.configure do
            migrations migrations_root
          end

          Hanami::Model::Migrator.create
        end

        it "it doesn't alter database" do
          Hanami::Model::Migrator.migrate
        end
      end
    end
  end
end
