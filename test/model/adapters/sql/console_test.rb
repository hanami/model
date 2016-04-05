require 'test_helper'

describe Hanami::Model::Adapters::Sql::Console do
  describe 'deciding on which SQL console class to use, based on URI scheme' do
    let(:uri) { 'username:password@localhost:1234/foo_development' }

    it 'mysql:// uri returns an instance of Console::Mysql' do
      console = Hanami::Model::Adapters::Sql::Console.new("mysql://#{uri}").send(:console)
      console.must_be_kind_of(Hanami::Model::Adapters::Sql::Consoles::Mysql)
    end

    it 'mysql2:// uri returns an instance of Console::Mysql' do
      console = Hanami::Model::Adapters::Sql::Console.new("mysql2://#{uri}").send(:console)
      console.must_be_kind_of(Hanami::Model::Adapters::Sql::Consoles::Mysql)
    end

    it 'postgres:// uri returns an instance of Console::Postgresql' do
      console = Hanami::Model::Adapters::Sql::Console.new("postgres://#{uri}").send(:console)
      console.must_be_kind_of(Hanami::Model::Adapters::Sql::Consoles::Postgresql)
    end

    it 'sqlite:// uri returns an instance of Console::Sqlite' do
      console = Hanami::Model::Adapters::Sql::Console.new("sqlite://#{uri}").send(:console)
      console.must_be_kind_of(Hanami::Model::Adapters::Sql::Consoles::Sqlite)
    end
  end
end
