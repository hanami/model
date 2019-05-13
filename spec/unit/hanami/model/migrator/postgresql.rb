# frozen_string_literal: true

require "ostruct"
require "securerandom"

RSpec.shared_examples "migrator_postgresql" do
  let(:migrator) do
    Hanami::Model::Migrator.new(configuration: configuration)
  end

  let(:random) { SecureRandom.hex(4) }

  # General variables
  let(:migrations)     { Pathname.new(__dir__ + "/../../../../support/fixtures/migrations") }
  let(:schema)         { nil }
  let(:config)         { OpenStruct.new(backend: :sql, url: url, _migrations: migrations, _schema: schema, migrations_logger: Hanami::Model::Migrator::Logger.new(ENV["HANAMI_DATABASE_LOGGER"])) }
  let(:configuration)  { Hanami::Model::Configuration.new(config) }

  # Variables for `apply` and `prepare`
  let(:root)              { Pathname.new("#{__dir__}/../../../../../tmp").expand_path }
  let(:source_migrations) { Pathname.new("#{__dir__}/../../../../support/fixtures/migrations") }

  let(:target_migrations) { root.join("migrations-#{random}") }

  after do
    migrator.drop rescue nil # rubocop:disable Style/RescueModifier
  end

  describe "PostgreSQL" do
    let(:database) { random }
    let(:url) do
      db = database

      Platform.match do
        engine(:ruby)  { "postgresql://127.0.0.1/#{db}?user=#{ENV['HANAMI_DATABASE_USERNAME']}" }
        engine(:jruby) { "jdbc:postgresql://127.0.0.1/#{db}?user=#{ENV['HANAMI_DATABASE_USERNAME']}" }
      end
    end

    describe "create" do
      before do
        migrator.create
      end

      it "creates the database" do
        connection = Sequel.connect(url)
        expect(connection.tables).to be_empty
      end

      it "raises error if database is busy" do
        Sequel.connect(url).tables
        expect { migrator.create }.to raise_error do |error|
          expect(error).to be_a(Hanami::Model::MigrationError)

          expect(error.message).to include("createdb: database creation failed. If the database exists,")
          expect(error.message).to include("then its console may be open. See this issue for more details:")
          expect(error.message).to include("https://github.com/hanami/model/issues/250")
        end
      end
    end

    describe "drop" do
      before do
        migrator.create
      end

      it "drops the database" do
        migrator.drop

        expect { Sequel.connect(url).tables }.to raise_error(Sequel::DatabaseConnectionError)
      end

      it "raises error if database doesn't exist" do
        migrator.drop # remove the first time

        expect { migrator.drop }
          .to raise_error(Hanami::Model::MigrationError, "Cannot find database: #{database}")
      end
    end

    describe "when executables are not available" do
      before do
        # We accomplish having a command not be available by setting PATH
        # to an empty string, which means *no commands* are available.
        @original_path = ENV["PATH"]
        ENV["PATH"] = ""
      end

      after do
        ENV["PATH"] = @original_path
      end

      it "raises MigrationError on missing `createdb`" do
        message = Platform.match do
          os(:macos).engine(:jruby) { "createdb" }
          default { "Could not find executable in your PATH: `createdb`" }
        end

        expect { migrator.create }.to raise_error do |exception|
          expect(exception).to         be_kind_of(Hanami::Model::MigrationError)
          expect(exception.message).to include(message)
        end
      end

      it "raises MigrationError on missing `dropdb`" do
        message = Platform.match do
          os(:macos).engine(:jruby) { "dropdb" }
          default { "Could not find executable in your PATH: `dropdb`" }
        end

        expect { migrator.drop }.to raise_error do |exception|
          expect(exception).to         be_kind_of(Hanami::Model::MigrationError)
          expect(exception.message).to include(message)
        end
      end
    end

    describe "migrate" do
      before do
        migrator.create
      end

      describe "when no migrations" do
        let(:migrations) { Pathname.new(__dir__ + "/../../../../support/fixtures/empty_migrations") }

        it "it doesn't alter database" do
          migrator.migrate

          connection = Sequel.connect(url)
          expect(connection.tables).to be_empty
        end
      end

      describe "when migrations are present" do
        it "migrates the database" do
          migrator.migrate

          connection = Sequel.connect(url)
          expect(connection.tables).to_not be_empty

          table = connection.schema(:reviews)

          name, options = table[0] # id
          expect(name).to eq(:id)

          expect(options.fetch(:allow_null)).to eq(false)
          # FIXME: determine how to assert it's a autoincrement
          # expect(options.fetch(:default)).to eq("nextval('reviews_id_seq'::regclass)")
          expect(options.fetch(:type)).to eq(:integer)
          expect(options.fetch(:db_type)).to eq("integer")
          expect(options.fetch(:primary_key)).to eq(true)
          expect(options.fetch(:auto_increment)).to eq(true)

          name, options = table[1] # title
          expect(name).to eq(:title)

          expect(options.fetch(:allow_null)).to eq(false)
          expect(options.fetch(:default)).to be_nil
          expect(options.fetch(:type)).to eq(:string)
          expect(options.fetch(:db_type)).to eq("text")
          expect(options.fetch(:primary_key)).to eq(false)

          name, options = table[2] # rating (second migration)
          expect(name).to eq(:rating)

          expect(options.fetch(:allow_null)).to eq(true)
          expect(options.fetch(:default)).to eq("0")
          expect(options.fetch(:type)).to eq(:integer)
          expect(options.fetch(:db_type)).to eq("integer")
          expect(options.fetch(:primary_key)).to eq(false)
        end
      end

      describe "when migrations are ran twice" do
        before do
          migrator.migrate
        end

        it "doesn't alter the schema" do
          migrator.migrate

          connection = Sequel.connect(url)
          expect(connection.tables).to_not be_empty
          expect(connection.tables).to include(:schema_migrations)
          expect(connection.tables).to include(:reviews)
        end
      end

      describe "migrate down" do
        before do
          migrator.migrate
        end

        it "migrates the database" do
          migrator.migrate(version: "20160831073534") # see spec/support/fixtures/migrations

          connection = Sequel.connect(url)
          expect(connection.tables).to_not be_empty

          table = connection.schema(:reviews)

          name, options = table[0] # id
          expect(name).to eq(:id)

          expect(options.fetch(:allow_null)).to eq(false)
          # FIXME: determine how to assert it's a autoincrement
          # expect(options.fetch(:default)).to eq("nextval('reviews_id_seq'::regclass)")
          expect(options.fetch(:type)).to eq(:integer)
          expect(options.fetch(:db_type)).to eq("integer")
          expect(options.fetch(:primary_key)).to eq(true)
          expect(options.fetch(:auto_increment)).to eq(true)

          name, options = table[1] # title
          expect(name).to eq(:title)

          expect(options.fetch(:allow_null)).to eq(false)
          expect(options.fetch(:default)).to be_nil
          expect(options.fetch(:type)).to eq(:string)
          expect(options.fetch(:db_type)).to eq("text")
          expect(options.fetch(:primary_key)).to eq(false)

          name, options = table[2] # rating (rolled back second migration)
          expect(name).to be_nil
          expect(options).to be_nil
        end
      end
    end

    describe "rollback" do
      before do
        migrator.create
      end

      describe "when no migrations" do
        let(:migrations) { Pathname.new(__dir__ + "/../../../../support/fixtures/empty_migrations") }

        it "it doesn't alter database" do
          migrator.rollback

          connection = Sequel.connect(url)
          expect(connection.tables).to be_empty
        end
      end

      describe "when migrations are present" do
        it "rollbacks one migration (default)" do
          migrator.migrate
          migrator.rollback

          connection = Sequel.connect(url)
          expect(connection.tables).to include(:reviews)

          table = connection.schema(:reviews)

          name, options = table[0] # id
          expect(name).to eq(:id)

          expect(options.fetch(:allow_null)).to eq(false)
          # FIXME: determine how to assert it's a autoincrement
          # expect(options.fetch(:default)).to eq("nextval('reviews_id_seq'::regclass)")
          expect(options.fetch(:type)).to eq(:integer)
          expect(options.fetch(:db_type)).to eq("integer")
          expect(options.fetch(:primary_key)).to eq(true)
          expect(options.fetch(:auto_increment)).to eq(true)

          name, options = table[1] # title
          expect(name).to eq(:title)

          expect(options.fetch(:allow_null)).to eq(false)
          expect(options.fetch(:default)).to be_nil
          expect(options.fetch(:type)).to eq(:string)
          expect(options.fetch(:db_type)).to eq("text")
          expect(options.fetch(:primary_key)).to eq(false)

          name, options = table[2] # rating (second migration)
          expect(name).to eq(nil)
          expect(options).to eq(nil)
        end

        it "rollbacks several migrations" do
          migrator.migrate
          migrator.rollback(steps: 2)

          connection = Sequel.connect(url)
          expect(connection.tables).to eq([:schema_migrations])
        end
      end
    end

    describe "apply" do
      let(:migrations) { target_migrations }
      let(:schema)     { root.join("schema-postgresql-#{random}.sql") }

      before do
        prepare_migrations_directory
        migrator.create
      end

      after do
        clean_migrations
      end

      it "migrates to latest version" do
        migrator.apply
        connection = Sequel.connect(url)
        migration = connection[:schema_migrations].to_a.last

        expect(migration.fetch(:filename)).to include("20160831090612") # see spec/support/fixtures/migrations
      end

      xit "dumps database schema.sql" do
        migrator.apply
        actual = schema.read

        if /public\.reviews/.match?(actual)
          #
          # POSTGRESQL 10
          #
          expect(actual).to include <<~SQL
            CREATE TABLE public.reviews (
                id integer NOT NULL,
                title text NOT NULL,
                rating integer DEFAULT 0
            );
          SQL

          expect(actual).to include <<~SQL
            CREATE SEQUENCE public.reviews_id_seq
                AS integer
                START WITH 1
                INCREMENT BY 1
                NO MINVALUE
                NO MAXVALUE
                CACHE 1;
          SQL

          expect(actual).to include <<~SQL
            ALTER SEQUENCE public.reviews_id_seq OWNED BY public.reviews.id;
          SQL

          expect(actual).to include <<~SQL
            ALTER TABLE ONLY public.reviews ALTER COLUMN id SET DEFAULT nextval('public.reviews_id_seq'::regclass);
          SQL

          expect(actual).to include <<~SQL
            ALTER TABLE ONLY public.reviews
                ADD CONSTRAINT reviews_pkey PRIMARY KEY (id);
          SQL

          expect(actual).to include <<~SQL
            CREATE TABLE public.schema_migrations (
                filename text NOT NULL
            );
          SQL

          expect(actual).to include <<~SQL
            COPY public.schema_migrations (filename) FROM stdin;
            20160831073534_create_reviews.rb
            20160831090612_add_rating_to_reviews.rb
          SQL

          expect(actual).to include <<~SQL
            ALTER TABLE ONLY public.schema_migrations
                ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (filename);
          SQL
        else
          #
          # POSTGRESQL 9
          #
          expect(actual).to include <<~SQL
            CREATE TABLE reviews (
                id integer NOT NULL,
                title text NOT NULL,
                rating integer DEFAULT 0
            );
          SQL

          expect(actual).to include <<~SQL
            CREATE SEQUENCE reviews_id_seq
                START WITH 1
                INCREMENT BY 1
                NO MINVALUE
                NO MAXVALUE
                CACHE 1;
          SQL

          expect(actual).to include <<~SQL
            ALTER SEQUENCE reviews_id_seq OWNED BY reviews.id;
          SQL

          expect(actual).to include <<~SQL
            ALTER TABLE ONLY reviews ALTER COLUMN id SET DEFAULT nextval('reviews_id_seq'::regclass);
          SQL

          expect(actual).to include <<~SQL
            ALTER TABLE ONLY reviews
                ADD CONSTRAINT reviews_pkey PRIMARY KEY (id);
          SQL

          expect(actual).to include <<~SQL
            CREATE TABLE schema_migrations (
                filename text NOT NULL
            );
          SQL

          expect(actual).to include <<~SQL
            COPY schema_migrations (filename) FROM stdin;
            20160831073534_create_reviews.rb
            20160831090612_add_rating_to_reviews.rb
          SQL

          expect(actual).to include <<~SQL
            ALTER TABLE ONLY schema_migrations
                ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (filename);
          SQL
        end
      end

      it "deletes all the migrations" do
        migrator.apply
        expect(target_migrations.children).to be_empty
      end

      context "when a system call fails" do
        before do
          expect(migrator).to receive(:adapter).at_least(:once).and_return(adapter)
        end

        let(:adapter) { Hanami::Model::Migrator::Adapter.for(configuration) }

        it "raises error when fails to dump database structure" do
          expect(adapter).to receive(:dump_structure).and_raise(Hanami::Model::MigrationError, message = "there was a problem")
          expect { migrator.apply }.to raise_error(Hanami::Model::MigrationError, message)

          expect(target_migrations.children).to_not be_empty
        end

        it "raises error when fails to dump migrations data" do
          expect(adapter).to receive(:dump_migrations_data).and_raise(Hanami::Model::MigrationError, message = "there was another problem")
          expect { migrator.apply }.to raise_error(Hanami::Model::MigrationError, message)

          expect(target_migrations.children).to_not be_empty
        end
      end
    end

    describe "prepare" do
      let(:migrations) { target_migrations }
      let(:schema)     { root.join("schema-postgresql-#{random}.sql") }

      before do
        prepare_migrations_directory
        migrator.create
      end

      after do
        clean_migrations
      end

      it "creates database, loads schema and migrate" do
        # Simulate already existing schema.sql, without existing database and pending migrations
        Hanami::Model::Migrator::Adapter.for(configuration).dump

        migration = target_migrations.join("20160831095616_create_abuses.rb")
        File.open(migration, "w+") do |f|
          f.write <<-RUBY
          Hanami::Model.migration do
            change do
              create_table :abuses do
                primary_key :id
              end
            end
          end
          RUBY
        end

        migrator.prepare

        connection = Sequel.connect(url)
        tables = connection.tables
        expect(tables).to include(:schema_migrations)
        expect(tables).to include(:reviews)
        expect(tables).to include(:abuses)

        FileUtils.rm_f migration
      end

      it "works even if schema doesn't exist" do
        # Simulate no database, no schema and pending migrations
        FileUtils.rm_f schema

        migrator.prepare

        connection = Sequel.connect(url)
        expect(connection.tables).to include(:schema_migrations)
        expect(connection.tables).to include(:reviews)
      end

      it "drops the database and recreates it" do
        migrator.prepare

        connection = Sequel.connect(url)
        expect(connection.tables).to include(:schema_migrations)
        expect(connection.tables).to include(:reviews)
      end
    end

    describe "version" do
      before do
        migrator.create
      end

      describe "when no migrations were ran" do
        it "returns nil" do
          expect(migrator.version).to be_nil
        end
      end

      describe "with migrations" do
        before do
          migrator.migrate
        end

        it "returns current database version" do
          expect(migrator.version).to eq("20160831090612") # see spec/support/fixtures/migrations)
        end
      end
    end
  end

  private

  def prepare_migrations_directory
    target_migrations.mkpath
    FileUtils.cp_r(Dir.glob("#{source_migrations}/*.rb"), target_migrations)
  end

  def clean_migrations
    FileUtils.rm_rf(target_migrations)
    FileUtils.rm(schema) if schema.exist?
  end
end
