require 'test_helper'
require 'lotus/model/migrator'

describe 'Memory Database Migration' do
  let(:adapter_prefix) { 'jdbc:' if Lotus::Utils.jruby?  }

  # Unfornatelly we need to explicitly include `::memory:` for JDBC
  # https://github.com/jeremyevans/sequel/blob/master/lib/sequel/adapters/jdbc/sqlite.rb#L61
  #
  let(:adapter_sufix)  { Lotus::Utils.jruby? ? ':memory:' : '/' }

  before do
    Lotus::Model.unload!
  end

  after do
    Lotus::Model::Migrator.drop rescue nil
    Lotus::Model.unload!
  end

  describe 'SQLite In Memory' do
    before do
      @uri = uri = "#{ adapter_prefix }sqlite:#{ adapter_sufix }"

      Lotus::Model.configure do
        adapter type: :sql, uri: uri
        migrations __dir__ + '/../../fixtures/migrations'
      end
    end

    after(:each) do
      SQLite3::Database.new(@uri) { |db| db.close } if File.exist?(@uri)
    end

    describe "create" do
      it "does nothing" do
        Lotus::Model::Migrator.create

        connection = Sequel.connect(@uri)
        connection.tables.must_be :empty?
      end
    end

    describe "drop" do
      before do
        Lotus::Model::Migrator.create
      end

      it "does nothing" do
        Lotus::Model::Migrator.drop

        connection = Sequel.connect(@uri)
        connection.tables.must_be :empty?
      end
    end

    describe "migrate" do
      before do
        Lotus::Model::Migrator.create
      end

      describe "when no migrations" do
        before do
          @migrations_root = migrations_root = Pathname.new(__dir__ + '/../../fixtures/empty_migrations')

          Lotus::Model.configure do
            migrations migrations_root
          end

          Lotus::Model::Migrator.create
        end

        it "it doesn't alter database" do
          Lotus::Model::Migrator.migrate
        end
      end
    end
  end
end
