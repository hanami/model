# frozen_string_literal: true

RSpec.describe Hanami::Model::Configuration do
  before do
    database_directory = Pathname.pwd.join("tmp", "db")
    database_directory.join("migrations").mkpath

    FileUtils.touch database_directory.join("schema.sql")
  end

  let(:subject) { Hanami::Model::Configuration.new(configurator) }

  let(:configurator) do
    adapter_url = url

    Hanami::Model::Configurator.build do
      adapter :sql, adapter_url

      migrations "tmp/db/migrations"
      schema     "tmp/db/schema.sql"
    end
  end

  let(:url) do
    db = "tmp/db/bookshelf.sqlite"

    Platform.match do
      engine(:ruby)  { "sqlite://#{db}" }
      engine(:jruby) { "jdbc:sqlite://#{db}" }
    end
  end

  describe "#url" do
    it "equals to the configured url" do
      expect(subject.url).to eq(url)
    end
  end

  describe "#connection" do
    it "returns a raw connection aganist the database" do
      connection = subject.connection

      expect(connection).to be_a_kind_of(Sequel::Database)
      expect(connection.url).to eq(url)
    end
  end

  describe "#gateway" do
    it "returns default ROM gateway" do
      gateway = subject.gateway

      expect(gateway).to be_a_kind_of(ROM::Gateway)
      expect(gateway.connection).to eq(subject.connection)
    end
  end

  describe "#root" do
    it "returns current directory" do
      expect(subject.root).to eq(Pathname.pwd)
    end
  end

  describe "#migrations" do
    it "returns path to migrations" do
      expected = subject.root.join("tmp", "db", "migrations")

      expect(subject.migrations).to eq(expected)
    end
  end

  describe "#schema" do
    it "returns path to database schema" do
      expected = subject.root.join("tmp", "db", "schema.sql")

      expect(subject.schema).to eq(expected)
    end
  end
end
