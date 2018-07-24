# frozen_string_literal: true

RSpec.describe Hanami::Model::Migrator::Connection do
  extend PlatformHelpers

  let(:connection) { Hanami::Model::Migrator::Connection.new(hanami_model_configuration) }

  describe "when not a jdbc connection" do
    let(:hanami_model_configuration) { OpenStruct.new(url: url, migrations_logger: Hanami::Model::Migrator::Logger.new(StringIO.new)) }
    let(:url) { "postgresql://postgres:s3cr3T@127.0.0.1:5432/database" }

    describe "#jdbc?" do
      it "returns false" do
        expect(connection.jdbc?).to eq(false)
      end
    end

    describe "#global_uri" do
      it "returns connection URI without database" do
        expect(connection.global_uri.scan("database").empty?).to eq(true)
      end
    end

    describe "#parsed_uri?" do
      it "returns an URI instance" do
        expect(connection.parsed_uri).to be_a_kind_of(URI)
      end
    end

    describe "#host" do
      it "returns configured host" do
        expect(connection.host).to eq("127.0.0.1")
      end

      describe "when the host is only specified in the URI" do
        let(:url) { "postgresql://127.0.0.1/database" }

        it "returns configured host" do
          expect(connection.host).to eq("127.0.0.1")
        end
      end

      describe "when the host is only specified in the query" do
        let(:url) { "postgresql:///database?host=0.0.0.0" }

        it "returns the host specified in the query param" do
          expect(connection.host).to eql("0.0.0.0")
        end
      end

      describe "when the host is specified as a socket" do
        let(:url) { "postgresql:///database?host=/path/to/my/sock" }

        it "returns the path to the socket specified in the query param" do
          expect(connection.host).to eql("/path/to/my/sock")
        end
      end

      describe "when the host is specified in both the URI and query" do
        let(:url) { "postgresql://127.0.0.1/database?host=0.0.0.0" }

        it "prefers the host from the URI" do
          expect(connection.host).to eql("127.0.0.1")
        end
      end
    end

    describe "#port" do
      it "returns configured port" do
        expect(connection.port).to eq(5432)
      end
    end

    describe "#database" do
      it "returns configured database" do
        expect(connection.database).to eq("database")
      end
    end

    describe "#user" do
      it "returns configured user" do
        expect(connection.user).to eq("postgres")
      end

      describe "when there is no user option" do
        let(:hanami_model_configuration) do
          OpenStruct.new(url: "postgresql://127.0.0.1:5432/database")
        end

        it "returns nil" do
          expect(connection.user).to be_nil
        end
      end
    end

    describe "#password" do
      it "returns configured password" do
        expect(connection.password).to eq("s3cr3T")
      end

      describe "when there is no password option" do
        let(:hanami_model_configuration) do
          OpenStruct.new(url: "postgresql://127.0.0.1/database")
        end

        it "returns nil" do
          expect(connection.password).to be_nil
        end
      end
    end

    describe "#raw" do
      let(:url) { ENV["HANAMI_DATABASE_URL"] }

      with_platform(db: :sqlite) do
        context "when sqlite" do
          it "returns raw sequel connection" do
            expected = Platform.match do
              engine(:ruby)  { Sequel::SQLite::Database }
              engine(:jruby) { Sequel::JDBC::Database }
            end

            expect(connection.raw).to be_kind_of(expected)
          end
        end
      end

      with_platform(db: :postgresql) do
        context "when postgres" do
          it "returns raw sequel connection" do
            expected = Platform.match do
              engine(:ruby)  { Sequel::Postgres::Database }
              engine(:jruby) { Sequel::JDBC::Database }
            end

            expect(connection.raw).to be_kind_of(expected)
          end
        end
      end

      with_platform(db: :mysql) do
        context "when mysql" do
          it "returns raw sequel connection" do
            expected = Platform.match do
              engine(:ruby)  { Sequel::Mysql2::Database }
              engine(:jruby) { Sequel::JDBC::Database }
            end

            expect(connection.raw).to be_kind_of(expected)
          end
        end
      end
    end

    # See https://www.postgresql.org/docs/current/static/libpq-connect.html#LIBPQ-CONNSTRING
    describe "when connection components in uri params" do
      let(:hanami_model_configuration) do
        OpenStruct.new(
          url: "postgresql:///mydb?host=localhost&port=6433&user=postgres&password=testpasswd"
        )
      end

      it "returns configured database" do
        expect(connection.database).to eq("mydb")
      end

      it "returns configured user" do
        expect(connection.user).to eq("postgres")
      end

      it "returns configured password" do
        expect(connection.password).to eq("testpasswd")
      end

      it "returns configured host" do
        expect(connection.host).to eq("localhost")
      end

      it "returns configured port" do
        expect(connection.port).to eq(6433)
      end

      describe "with blank port" do
        let(:hanami_model_configuration) do
          OpenStruct.new(
            url: "postgresql:///mydb?host=localhost&port=&user=postgres&password=testpasswd"
          )
        end

        it "raises an error" do
          expect(connection.port).to be_nil
        end
      end
    end
  end

  describe "when jdbc connection" do
    let(:hanami_model_configuration) do
      OpenStruct.new(
        url: "jdbc:postgresql://127.0.0.1:5432/database?user=postgres&password=s3cr3T"
      )
    end

    describe "#jdbc?" do
      it "returns true" do
        expect(connection.jdbc?).to eq(true)
      end
    end

    describe "#host" do
      it "returns configured host" do
        expect(connection.host).to eq("127.0.0.1")
      end
    end

    describe "#port" do
      it "returns configured port" do
        expect(connection.port).to eq(5432)
      end
    end

    describe "#user" do
      it "returns configured user" do
        expect(connection.user).to eq("postgres")
      end

      describe "when there is no user option" do
        let(:hanami_model_configuration) do
          OpenStruct.new(url: "jdbc:postgresql://127.0.0.1/database")
        end

        it "returns nil" do
          expect(connection.user).to be_nil
        end
      end
    end

    describe "#password" do
      it "returns configured password" do
        expect(connection.password).to eq("s3cr3T")
      end

      describe "when there is no password option" do
        let(:hanami_model_configuration) do
          OpenStruct.new(url: "jdbc:postgresql://127.0.0.1/database")
        end

        it "returns nil" do
          expect(connection.password).to be_nil
        end
      end
    end

    describe "#database" do
      it "returns configured database" do
        expect(connection.database).to eq("database")
      end
    end
  end
end
