# frozen_string_literal: true

require "hanami/model/sql/console"

RSpec.describe Hanami::Model::Sql::Console do
  describe "deciding on which SQL console class to use, based on URI scheme" do
    let(:uri) { "username:password@localhost:1234/foo_development" }

    case Database.engine
    when :sqlite
      it "sqlite:// uri returns an instance of Console::Sqlite" do
        console = Hanami::Model::Sql::Console.new("sqlite://#{uri}").send(:console)
        expect(console).to be_a_kind_of(Hanami::Model::Sql::Consoles::Sqlite)
      end
    when :postgresql
      it "postgres:// uri returns an instance of Console::Postgresql" do
        console = Hanami::Model::Sql::Console.new("postgres://#{uri}").send(:console)
        expect(console).to be_a_kind_of(Hanami::Model::Sql::Consoles::Postgresql)
      end

      it "postgresql:// uri returns an instance of Console::Postgresql" do
        console = Hanami::Model::Sql::Console.new("postgresql://#{uri}").send(:console)
        expect(console).to be_a_kind_of(Hanami::Model::Sql::Consoles::Postgresql)
      end
    when :mysql
      it "mysql:// uri returns an instance of Console::Mysql" do
        console = Hanami::Model::Sql::Console.new("mysql://#{uri}").send(:console)
        expect(console).to be_a_kind_of(Hanami::Model::Sql::Consoles::Mysql)
      end

      it "mysql2:// uri returns an instance of Console::Mysql" do
        console = Hanami::Model::Sql::Console.new("mysql2://#{uri}").send(:console)
        expect(console).to be_a_kind_of(Hanami::Model::Sql::Consoles::Mysql)
      end
    end
  end

  describe Database.engine.to_s do
    require_relative "./console/#{Database.engine}"
    include_examples "sql_console_#{Database.engine}"
  end
end
