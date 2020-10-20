# frozen_string_literal: true
RSpec.describe Hanami::Model::Sql do
  describe ".migration" do
    it "returns a new migration" do
      migration = Hanami::Model.migration {}

      expect(migration).to be_kind_of(Hanami::Model::Migration)
    end
  end

  describe ".function" do
    it "returns a database function" do
      function = described_class.function(:uuid_generate_v4)

      expect(function).to be_kind_of(Sequel::SQL::Function)
    end
  end

  describe ".literal" do
    it "returns a database literal" do
      literal = described_class.literal(input = "ROW('fuzzy dice', 42, 1.99)")

      expect(literal).to be_kind_of(Sequel::LiteralString)
      expect(literal).to eq(input)
    end
  end

  describe ".asc" do
    it "returns an asceding order clause" do
      clause = described_class.asc(input = :created_at)

      expect(clause).to be_kind_of(Sequel::SQL::OrderedExpression)
      expect(clause.expression).to eq(input)
      expect(clause.descending).to be(false)
    end
  end

  describe ".desc" do
    it "returns an descending order clause" do
      clause = described_class.desc(input = :created_at)

      expect(clause).to be_kind_of(Sequel::SQL::OrderedExpression)
      expect(clause.expression).to eq(input)
      expect(clause.descending).to be(true)
    end
  end
end
