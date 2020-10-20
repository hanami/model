# frozen_string_literal: true

RSpec.describe Hanami::Model::Migrator::Adapter do
  extend PlatformHelpers

  subject { described_class.new(connection) }

  let(:connection)    { instance_double("Hanami::Model::Migrator::Connection", database_type: database_type) }
  let(:database_type) { "unknown" }

  describe ".for" do
    before do
      expect(configuration).to receive(:url).at_least(:once).and_return(url)
    end

    let(:configuration) { instance_double("Hanami::Model::Configuration") }
    let(:url)           { ENV["HANAMI_DATABASE_URL"] }

    with_platform(db: :sqlite) do
      context "when sqlite" do
        it "returns sqlite adapter" do
          expect(described_class.for(configuration)).to be_kind_of(Hanami::Model::Migrator::SQLiteAdapter)
        end
      end
    end

    with_platform(db: :postgresql) do
      context "when postgresql" do
        it "returns postgresql adapter" do
          expect(described_class.for(configuration)).to be_kind_of(Hanami::Model::Migrator::PostgresAdapter)
        end
      end
    end

    with_platform(db: :mysql) do
      context "when mysql" do
        it "returns mysql adapter" do
          expect(described_class.for(configuration)).to be_kind_of(Hanami::Model::Migrator::MySQLAdapter)
        end
      end
    end

    context "when unknown" do
      let(:url) { "unknown" }

      it "returns generic adapter" do
        expect(described_class.for(configuration)).to be_kind_of(described_class)
      end
    end
  end

  describe "#create" do
    it "raises migration error" do
      expect { subject.create }.to raise_error(Hanami::Model::MigrationError, "Current adapter (#{database_type}) doesn't support create.")
    end
  end

  describe "#drop" do
    it "raises migration error" do
      expect { subject.drop }.to raise_error(Hanami::Model::MigrationError, "Current adapter (#{database_type}) doesn't support drop.")
    end
  end

  describe "#load" do
    it "raises migration error" do
      expect { subject.load }.to raise_error(Hanami::Model::MigrationError, "Current adapter (#{database_type}) doesn't support load.")
    end
  end

  describe "migrate" do
    it "raises migration error in case of error" do
      expect(connection).to receive(:raw)
      expect(Sequel::Migrator).to receive(:run).and_raise(Sequel::Migrator::Error.new("ouch"))

      expect { subject.migrate([], "-1") }.to raise_error(Hanami::Model::MigrationError, "ouch")
    end
  end
end
