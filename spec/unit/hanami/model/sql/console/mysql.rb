# frozen_string_literal: true

require "hanami/model/sql/consoles/mysql"

RSpec.shared_examples "sql_console_mysql" do
  let(:console) { Hanami::Model::Sql::Consoles::Mysql.new(uri) }

  describe "#connection_string" do
    let(:uri) { URI.parse("mysql://username:password@localhost:1234/foo_development") }

    it "returns a connection string" do
      expect(console.connection_string).to eq("mysql -h localhost -D foo_development -P 1234 -u username -p password")
    end
  end
end
