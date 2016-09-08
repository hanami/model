require 'test_helper'
require 'hanami/model/sql/console'

describe Hanami::Model::Sql::Console do
  describe 'deciding on which SQL console class to use, based on URI scheme' do
    let(:uri) { 'username:password@localhost:1234/foo_development' }

    case Database.engine
    when :sqlite
      it 'sqlite:// uri returns an instance of Console::Sqlite' do
        console = Hanami::Model::Sql::Console.new("sqlite://#{uri}").send(:console)
        console.must_be_kind_of(Hanami::Model::Sql::Consoles::Sqlite)
      end
    when :postgresql
      it 'postgres:// uri returns an instance of Console::Postgresql' do
        console = Hanami::Model::Sql::Console.new("postgres://#{uri}").send(:console)
        console.must_be_kind_of(Hanami::Model::Sql::Consoles::Postgresql)
      end
    when :mysql
      it 'mysql:// uri returns an instance of Console::Mysql' do
        console = Hanami::Model::Sql::Console.new("mysql://#{uri}").send(:console)
        console.must_be_kind_of(Hanami::Model::Sql::Consoles::Mysql)
      end

      it 'mysql2:// uri returns an instance of Console::Mysql' do
        console = Hanami::Model::Sql::Console.new("mysql2://#{uri}").send(:console)
        console.must_be_kind_of(Hanami::Model::Sql::Consoles::Mysql)
      end
    end
  end

  describe Database.engine.to_s do
    load "test/sql/console/#{Database.engine}.rb"
  end
end
