# frozen_string_literal: true

RSpec.describe Hanami::Model::Migrator::Logger do
  subject(:logger) { described_class.new(stream) }

  let(:stream) { File.open(File::NULL, "w") }

  shared_examples "supress `no such table` error for `schema_migrations` table" do |message|
    context "and text matches `schema_migrations` table error" do
      it "does not invoke Logger#add" do
        expect(logger).to_not receive(:add)

        logger.error(message)
      end

      it "returns true" do
        result = logger.error(message)

        expect(result).to eq(true)
      end
    end
  end

  shared_examples "supress `no such table` error for `schema_info` table" do |message|
    context "and text matches `schema_info` table error" do
      it "does not invoke Logger#add" do
        expect(logger).to_not receive(:add)

        logger.error(message)
      end

      it "returns true" do
        result = logger.error(message)

        expect(result).to eq(true)
      end
    end
  end

  shared_examples "does not supress common messages" do |message|
    context "and text refers to another table" do
      it "invokes Logger#add" do
        expect(logger)
          .to receive(:add)
          .once
          .with(Logger::ERROR, nil, message)

        logger.error(message)
      end

      it "returns true" do
        result = logger.error(message)

        expect(result).to eq(true)
      end
    end
  end

  describe "#error" do
    context "when sqlite" do
      include_examples "supress `no such table` error for `schema_migrations` table", "SQLite::SQLException: no such table: schema_migrations: SELECT NULL AS 'nil' FROM `schema_migrations` LIMIT 1"
      include_examples "supress `no such table` error for `schema_info` table", "SQLite::SQLException: no such table: schema_info: SELECT NULL AS 'nil' FROM `schema_info` LIMIT 1"
      include_examples "does not supress common messages", "SQLite::SQLException: no such table: my_table: SELECT NULL AS 'nil' FROM `my_table` LIMIT 1"
    end

    context "when postgres" do
      include_examples "supress `no such table` error for `schema_migrations` table", "PG::UndefinedTable: ERROR:  relation \"schema_migrations\" does not exist"
      include_examples "supress `no such table` error for `schema_info` table", "PG::UndefinedTable: ERROR:  relation \"schema_info\" does not exist"
      include_examples "does not supress common messages", "PG::UndefinedTable: ERROR:  relation \"my_table\" does not exist"
    end

    context "when mysql" do
      include_examples "supress `no such table` error for `schema_migrations` table", "Mysql2::Error: Table 'bookshelf_development.schema_migrations' doesn't exist: SELECT NULL AS `nil` FROM `schema_migrations` LIMIT 1"
      include_examples "supress `no such table` error for `schema_info` table", "Mysql2::Error: Table 'bookshelf_development.schema_info' doesn't exist: SELECT NULL AS `nil` FROM `schema_info` LIMIT 1"
      include_examples "does not supress common messages", "Mysql2::Error: Table 'bookshelf_development.my_table' doesn't exist: SELECT NULL AS `nil` FROM `my_table` LIMIT 1"
    end
  end
end
