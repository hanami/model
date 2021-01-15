# frozen_string_literal: true

require "securerandom"

RSpec.describe "Repository (base)" do
  extend PlatformHelpers

  describe "#find" do
    it "finds record by primary key" do
      repository = UserRepository.new
      user = repository.create(name: "L")
      found = repository.find(user.id)

      expect(found).to eq(user)
    end

    it "returns nil when nil is given" do
      repository = UserRepository.new
      repository.create(name: "L")
      found = repository.find(nil)

      expect(found).to be_nil
    end

    it "returns nil for missing record" do
      repository = UserRepository.new
      found = repository.find("9999999")

      expect(found).to be_nil
    end

    # See https://github.com/hanami/model/issues/374
    describe "with non-autoincrement primary key" do
      before do
        repository.clear
      end

      let(:repository) { LabelRepository.new }
      let(:id)         { 1 }

      it "raises error" do
        repository.create(id: id)

        expect { repository.find(id) }
          .to raise_error(Hanami::Model::MissingPrimaryKeyError, "Missing primary key for :labels")
      end
    end

    # See https://github.com/hanami/model/issues/399
    describe "with custom relation" do
      it "finds record by primary key" do
        repository = AccessTokenRepository.new
        access_token = repository.create(token: "123")
        found        = repository.find(access_token.id)

        expect(found).to eq(access_token)
      end
    end
  end

  describe "#all" do
    it "returns all the records" do
      repository = UserRepository.new
      user = repository.create(name: "L")

      expect(repository.all).to be_an_instance_of(Array)
      expect(repository.all).to include(user)
    end
  end

  describe "#first" do
    it "returns first record from table" do
      repository = UserRepository.new
      repository.clear

      user = repository.create(name: "James Hetfield")
      repository.create(name: "Tom")

      expect(repository.first).to eq(user)
    end
  end

  describe "#last" do
    it "returns last record from table" do
      repository = UserRepository.new
      repository.clear

      repository.create(name: "Tom")
      user = repository.create(name: "Ella Fitzgerald")

      expect(repository.last).to eq(user)
    end
  end

  # https://github.com/hanami/model/issues/473
  describe "querying" do
    it "allows to access relation attributes via square bracket syntax" do
      repository = UserRepository.new
      repository.clear

      expected = [repository.create(name: "Ella"),
                  repository.create(name: "Bella")]
      repository.create(name: "Jon")

      actual = repository.by_matching_name("%ella%")
      expect(actual).to eq(expected)
    end
  end

  describe "#clear" do
    it "clears all the records" do
      repository = UserRepository.new
      repository.create(name: "L")

      repository.clear
      expect(repository.all).to be_empty
    end
  end

  describe "relation" do
    describe "read" do
      it "reads records from the database given a raw query string" do
        repository = UserRepository.new
        repository.create(name: "L")

        users = repository.find_all_by_manual_query
        expect(users).to be_a_kind_of(Array)

        user = users.first
        expect(user).to be_a_kind_of(User)
      end
    end
  end

  describe "#create" do
    it "creates record from data" do
      repository = UserRepository.new
      user = repository.create(name: "L")

      expect(user).to be_an_instance_of(User)
      expect(user.id).to_not be_nil
      expect(user.name).to eq("L")
    end

    it "creates record from entity" do
      entity = User.new(name: "L")
      repository = UserRepository.new
      user = repository.create(entity)

      # It doesn't mutate original entity
      expect(entity.id).to be_nil

      expect(user).to be_an_instance_of(User)
      expect(user.id).to_not be_nil
      expect(user.name).to eq("L")
    end

    with_platform(engine: :jruby, db: :sqlite) do
      it "automatically touches timestamps"
    end

    unless_platform(engine: :jruby, db: :sqlite) do
      it "automatically touches timestamps" do
        repository = UserRepository.new
        user = repository.create(name: "L")

        expect(user.created_at).to be_within(2).of(Time.now.utc)
        expect(user.updated_at).to be_within(2).of(Time.now.utc)
      end

      it "respects given timestamps" do
        repository = UserRepository.new
        given_time = Time.new(2010, 1, 1, 12, 0, 0, "+00:00")

        user = repository.create(name: "L", created_at: given_time, updated_at: given_time)

        expect(user.created_at).to be_within(2).of(given_time)
        expect(user.updated_at).to be_within(2).of(given_time)
      end

      it "can update timestamps" do
        repository = UserRepository.new
        user = repository.create(name: "L")
        expect(user.created_at).to be_within(2).of(Time.now.utc)
        expect(user.updated_at).to be_within(2).of(Time.now.utc)

        given_time = Time.new(2010, 1, 1, 12, 0, 0, "+00:00")
        updated = repository.update(
          user.id,
          created_at: given_time,
          updated_at: given_time
        )

        expect(updated.name).to eq("L")
        expect(updated.created_at).to be_within(2).of(given_time)
        expect(updated.updated_at).to be_within(2).of(given_time)
      end

      # Bug: https://github.com/hanami/model/issues/412
      it "can have only creation timestamp" do
        user = UserRepository.new.create(name: "L")
        repository = AvatarRepository.new
        account = repository.create(url: "http://foo.com", user_id: user.id)
        expect(account.created_at).to be_within(2).of(Time.now.utc)
      end
    end

    # Bug: https://github.com/hanami/model/issues/237
    it "respects database defaults" do
      repository = UserRepository.new
      user = repository.create(name: "L")

      expect(user.comments_count).to eq(0)
    end

    # Bug: https://github.com/hanami/model/issues/272
    it "accepts booleans as attributes" do
      user = UserRepository.new.create(name: "L", active: false)
      expect(user.active).to eq(false)
    end

    it "raises error when generic database error is raised"
    # it 'raises error when generic database error is raised' do
    #   expected_error = Hanami::Model::DatabaseError
    #   message = Platform.match do
    #     engine(:ruby).db(:sqlite)  { 'SQLite3::SQLException: table users has no column named bogus' }
    #     engine(:jruby).db(:sqlite) { 'Java::JavaSql::SQLException: table users has no column named bogus' }

    #     engine(:ruby).db(:postgresql)  { 'PG::UndefinedColumn: ERROR:  column "bogus" of relation "users" does not exist' }
    #     engine(:jruby).db(:postgresql) { 'bogus' }

    #     engine(:ruby).db(:mysql)  { "Mysql2::Error: Unknown column 'bogus' in 'field list'" }
    #     engine(:jruby).db(:mysql) { 'bogus' }
    #   end

    #   expect { UserRepository.new.create(name: 'L', bogus: 23) }.to raise_error do |error|
    #     expect(error).to be_a(expected_error)
    #     expect(error.message).to include(message)
    #   end
    # end

    it 'raises error when "not null" database constraint is violated' do
      expected_error = Hanami::Model::NotNullConstraintViolationError
      message = Platform.match do
        engine(:ruby).db(:sqlite)  { "SQLite3::ConstraintException" }
        engine(:jruby).db(:sqlite) { "Java::OrgSqlite::SQLiteException: [SQLITE_CONSTRAINT_NOTNULL]  A NOT NULL constraint failed (NOT NULL constraint failed: users.active)" }

        engine(:ruby).db(:postgresql)  { 'PG::NotNullViolation: ERROR:  null value in column "active" of relation "users" violates not-null constraint' }
        engine(:jruby).db(:postgresql) { 'Java::OrgPostgresqlUtil::PSQLException: ERROR: null value in column "active" violates not-null constraint' }

        engine(:ruby).db(:mysql)  { "Mysql2::Error: Column 'active' cannot be null" }
        engine(:jruby).db(:mysql) { "Java::ComMysqlJdbcExceptionsJdbc4::MySQLIntegrityConstraintViolationException: Column 'active' cannot be null" }
      end

      expect { UserRepository.new.create(name: "L", active: nil) }.to raise_error do |error|
        expect(error).to be_a(expected_error)
        expect(error.message).to include(message)
      end
    end

    it 'raises error when "unique constraint" is violated' do
      email = "user@#{SecureRandom.uuid}.test"

      expected_error = Hanami::Model::UniqueConstraintViolationError
      message = Platform.match do
        engine(:ruby).db(:sqlite)  { "SQLite3::ConstraintException" }
        engine(:jruby).db(:sqlite) { "Java::OrgSqlite::SQLiteException: [SQLITE_CONSTRAINT_UNIQUE]  A UNIQUE constraint failed (UNIQUE constraint failed: users.email)" }

        engine(:ruby).db(:postgresql)  { 'PG::UniqueViolation: ERROR:  duplicate key value violates unique constraint "users_email_index"' }
        engine(:jruby).db(:postgresql) { %(Java::OrgPostgresqlUtil::PSQLException: ERROR: duplicate key value violates unique constraint "users_email_index"\n  Detail: Key (email)=(#{email}) already exists.) }

        engine(:ruby).db(:mysql)  { "Mysql2::Error: Duplicate entry '#{email}' for key 'users.users_email_index'" }
        engine(:jruby).db(:mysql) { "Java::ComMysqlJdbcExceptionsJdbc4::MySQLIntegrityConstraintViolationException: Duplicate entry '#{email}' for key 'users_email_index'" }
      end

      repository = UserRepository.new
      repository.create(name: "Test", email: email)

      expect { repository.create(name: "L", email: email) }.to raise_error do |error|
        expect(error).to be_a(expected_error)
        expect(error.message).to include(message)
      end
    end

    it 'raises error when "foreign key" constraint is violated' do
      expected_error = Hanami::Model::ForeignKeyConstraintViolationError
      message = Platform.match do
        engine(:ruby).db(:sqlite)  { "SQLite3::ConstraintException" }
        engine(:jruby).db(:sqlite) { "Java::OrgSqlite::SQLiteException: [SQLITE_CONSTRAINT_FOREIGNKEY]  A foreign key constraint failed (FOREIGN KEY constraint failed)" }

        engine(:ruby).db(:postgresql)  { 'PG::ForeignKeyViolation: ERROR:  insert or update on table "avatars" violates foreign key constraint "avatars_user_id_fkey"' }
        engine(:jruby).db(:postgresql) { 'Java::OrgPostgresqlUtil::PSQLException: ERROR: insert or update on table "avatars" violates foreign key constraint "avatars_user_id_fkey"' }

        engine(:ruby).db(:mysql)  { "Mysql2::Error: Cannot add or update a child row: a foreign key constraint fails" }
        engine(:jruby).db(:mysql) { "Java::ComMysqlJdbcExceptionsJdbc4::MySQLIntegrityConstraintViolationException: Cannot add or update a child row: a foreign key constraint fails (`hanami_model`.`avatars`, CONSTRAINT `avatars_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE)" }
      end

      expect { AvatarRepository.new.create(user_id: 999_999_999, url: "url") }.to raise_error do |error|
        expect(error).to be_a(expected_error)
        expect(error.message).to include(message)
      end
    end

    # For MySQL [...] The CHECK clause is parsed but ignored by all storage engines.
    # http://dev.mysql.com/doc/refman/5.7/en/create-table.html
    unless_platform(db: :mysql) do
      it 'raises error when "check" constraint is violated' do
        expected = Hanami::Model::CheckConstraintViolationError

        message = Platform.match do
          engine(:ruby).db(:sqlite)  { "SQLite3::ConstraintException: CHECK constraint failed" }
          engine(:jruby).db(:sqlite) { "Java::OrgSqlite::SQLiteException: [SQLITE_CONSTRAINT_CHECK]  A CHECK constraint failed (CHECK constraint failed: users)" }

          engine(:ruby).db(:postgresql)  { 'PG::CheckViolation: ERROR:  new row for relation "users" violates check constraint "users_age_check"' }
          engine(:jruby).db(:postgresql) { 'Java::OrgPostgresqlUtil::PSQLException: ERROR: new row for relation "users" violates check constraint "users_age_check"' }
        end

        expect { UserRepository.new.create(name: "L", age: 1) }.to raise_error do |error|
          expect(error).to         be_a(expected)
          expect(error.message).to include(message)
        end
      end

      it "raises error when constraint is violated" do
        expected = Hanami::Model::CheckConstraintViolationError

        message = Platform.match do
          engine(:ruby).db(:sqlite)  { "SQLite3::ConstraintException: CHECK constraint failed" }
          engine(:jruby).db(:sqlite) { "Java::OrgSqlite::SQLiteException: [SQLITE_CONSTRAINT_CHECK]  A CHECK constraint failed (CHECK constraint failed: comments_count_constraint)" }

          engine(:ruby).db(:postgresql)  { 'PG::CheckViolation: ERROR:  new row for relation "users" violates check constraint "comments_count_constraint"' }
          engine(:jruby).db(:postgresql) { 'Java::OrgPostgresqlUtil::PSQLException: ERROR: new row for relation "users" violates check constraint "comments_count_constraint"' }
        end

        expect { UserRepository.new.create(name: "L", comments_count: -1) }.to raise_error do |error|
          expect(error).to         be_a(expected)
          expect(error.message).to include(message)
        end
      end
    end
  end

  describe "#update" do
    it "updates record from data" do
      repository = UserRepository.new
      user = repository.create(name: "L")
      updated = repository.update(user.id, name: "Luca")

      expect(updated).to be_an_instance_of(User)
      expect(updated.id).to eq(user.id)
      expect(updated.name).to eq("Luca")
    end

    it "updates record from entity" do
      entity = User.new(name: "Luca")
      repository = UserRepository.new
      user = repository.create(name: "L")
      updated = repository.update(user.id, entity)

      # It doesn't mutate original entity
      expect(entity.id).to be_nil

      expect(updated).to be_an_instance_of(User)
      expect(updated.id).to eq(user.id)
      expect(updated.name).to eq("Luca")
    end

    it "returns nil when record cannot be found" do
      repository = UserRepository.new
      updated = repository.update("9999999", name: "Luca")

      expect(updated).to be_nil
    end

    with_platform(engine: :jruby, db: :sqlite) do
      it "automatically touches timestamps"
    end

    unless_platform(engine: :jruby, db: :sqlite) do
      it "automatically touches timestamps" do
        repository = UserRepository.new
        user = repository.create(name: "L")
        sleep 0.1
        updated = repository.update(user.id, name: "Luca")

        expect(updated.created_at).to be_within(2).of(user.created_at)
        expect(updated.updated_at).to be_within(2).of(Time.now)
      end
    end

    it "raises error when generic database error is raised"
    # it 'raises error when generic database error is raised' do
    #   expected_error = Hanami::Model::DatabaseError
    #   message = Platform.match do
    #     engine(:ruby).db(:sqlite)  { 'SQLite3::SQLException: no such column: bogus' }
    #     engine(:jruby).db(:sqlite) { 'Java::JavaSql::SQLException: no such column: bogus' }

    #     engine(:ruby).db(:postgresql)  { 'PG::UndefinedColumn: ERROR:  column "bogus" of relation "users" does not exist' }
    #     engine(:jruby).db(:postgresql) { 'bogus' }

    #     engine(:ruby).db(:mysql)  { "Mysql2::Error: Unknown column 'bogus' in 'field list'" }
    #     engine(:jruby).db(:mysql) { 'bogus' }
    #   end

    #   repository = UserRepository.new
    #   user = repository.create(name: 'L')

    #   expect { repository.update(user.id, bogus: 23) }.to raise_error do |error|
    #     expect(error).to be_a(expected_error)
    #     expect(error.message).to include(message)
    #   end
    # end

    # MySQL doesn't raise an error on CI
    unless_platform(os: :linux, engine: :ruby, db: :mysql) do
      it 'raises error when "not null" database constraint is violated' do
        expected_error = Hanami::Model::NotNullConstraintViolationError
        message = Platform.match do
          engine(:ruby).db(:sqlite)  { "SQLite3::ConstraintException" }
          engine(:jruby).db(:sqlite) { "Java::OrgSqlite::SQLiteException: [SQLITE_CONSTRAINT_NOTNULL]  A NOT NULL constraint failed (NOT NULL constraint failed: users.active)" }

          engine(:ruby).db(:postgresql)  { 'PG::NotNullViolation: ERROR:  null value in column "active" of relation "users" violates not-null constraint' }
          engine(:jruby).db(:postgresql) { 'Java::OrgPostgresqlUtil::PSQLException: ERROR: null value in column "active" violates not-null constraint' }

          engine(:ruby).db(:mysql)  { "Mysql2::Error: Column 'active' cannot be null" }
          engine(:jruby).db(:mysql) { "Java::ComMysqlJdbcExceptionsJdbc4::MySQLIntegrityConstraintViolationException: Column 'active' cannot be null" }
        end

        repository = UserRepository.new
        user = repository.create(name: "L")

        expect { repository.update(user.id, active: nil) }.to raise_error do |error|
          expect(error).to be_a(expected_error)
          expect(error.message).to include(message)
        end
      end
    end

    it 'raises error when "unique constraint" is violated' do
      email = "update@#{SecureRandom.uuid}.test"

      expected_error = Hanami::Model::UniqueConstraintViolationError
      message = Platform.match do
        engine(:ruby).db(:sqlite)  { "SQLite3::ConstraintException" }
        engine(:jruby).db(:sqlite) { "Java::OrgSqlite::SQLiteException: [SQLITE_CONSTRAINT_UNIQUE]  A UNIQUE constraint failed (UNIQUE constraint failed: users.email)" }

        engine(:ruby).db(:postgresql)  { 'PG::UniqueViolation: ERROR:  duplicate key value violates unique constraint "users_email_index"' }
        engine(:jruby).db(:postgresql) { 'Java::OrgPostgresqlUtil::PSQLException: ERROR: duplicate key value violates unique constraint "users_email_index"' }

        engine(:ruby).db(:mysql)  { "Mysql2::Error: Duplicate entry '#{email}' for key 'users.users_email_index'" }
        engine(:jruby).db(:mysql) { "Java::ComMysqlJdbcExceptionsJdbc4::MySQLIntegrityConstraintViolationException: Duplicate entry '#{email}' for key 'users_email_index'" }
      end

      repository = UserRepository.new
      user = repository.create(name: "L")
      repository.create(name: "UpdateTest", email: email)

      expect { repository.update(user.id, email: email) }.to raise_error do |error|
        expect(error).to be_a(expected_error)
        expect(error.message).to include(message)
      end
    end

    it 'raises error when "foreign key" constraint is violated' do
      expected_error = Hanami::Model::ForeignKeyConstraintViolationError
      message = Platform.match do
        engine(:ruby).db(:sqlite)  { "SQLite3::ConstraintException" }
        engine(:jruby).db(:sqlite) { "Java::OrgSqlite::SQLiteException: [SQLITE_CONSTRAINT_FOREIGNKEY]  A foreign key constraint failed (FOREIGN KEY constraint failed)" }

        engine(:ruby).db(:postgresql)  { 'PG::ForeignKeyViolation: ERROR:  insert or update on table "avatars" violates foreign key constraint "avatars_user_id_fkey"' }
        engine(:jruby).db(:postgresql) { 'Java::OrgPostgresqlUtil::PSQLException: ERROR: insert or update on table "avatars" violates foreign key constraint "avatars_user_id_fkey"' }

        engine(:ruby).db(:mysql)  { "Mysql2::Error: Cannot add or update a child row: a foreign key constraint fails" }
        engine(:jruby).db(:mysql) { "Java::ComMysqlJdbcExceptionsJdbc4::MySQLIntegrityConstraintViolationException: Cannot add or update a child row: a foreign key constraint fails (`hanami_model`.`avatars`, CONSTRAINT `avatars_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE)" }
      end

      user = UserRepository.new.create(name: "L")
      repository = AvatarRepository.new
      avatar = repository.create(user_id: user.id, url: "a valid url")

      expect { repository.update(avatar.id, user_id: 999_999_999) }.to raise_error do |error|
        expect(error).to be_a(expected_error)
        expect(error.message).to include(message)
      end
    end

    # For MySQL [...] The CHECK clause is parsed but ignored by all storage engines.
    # http://dev.mysql.com/doc/refman/5.7/en/create-table.html
    unless_platform(db: :mysql) do
      it 'raises error when "check" constraint is violated' do
        expected = Hanami::Model::CheckConstraintViolationError

        message = Platform.match do
          engine(:ruby).db(:sqlite)   { "SQLite3::ConstraintException: CHECK constraint failed" }
          engine(:jruby).db(:sqlite)  { "Java::OrgSqlite::SQLiteException: [SQLITE_CONSTRAINT_CHECK]  A CHECK constraint failed (CHECK constraint failed: users)" }

          engine(:ruby).db(:postgresql)  { 'PG::CheckViolation: ERROR:  new row for relation "users" violates check constraint "users_age_check"' }
          engine(:jruby).db(:postgresql) { 'Java::OrgPostgresqlUtil::PSQLException: ERROR: new row for relation "users" violates check constraint "users_age_check"' }
        end

        repository = UserRepository.new
        user = repository.create(name: "L")

        expect { repository.update(user.id, age: 17) }.to raise_error do |error|
          expect(error).to         be_a(expected)
          expect(error.message).to include(message)
        end
      end

      it "raises error when constraint is violated" do
        expected = Hanami::Model::CheckConstraintViolationError

        message = Platform.match do
          engine(:ruby).db(:sqlite)   { "SQLite3::ConstraintException: CHECK constraint failed" }
          engine(:jruby).db(:sqlite)  { "Java::OrgSqlite::SQLiteException: [SQLITE_CONSTRAINT_CHECK]  A CHECK constraint failed (CHECK constraint failed: comments_count_constraint)" }

          engine(:ruby).db(:postgresql)  { 'PG::CheckViolation: ERROR:  new row for relation "users" violates check constraint "comments_count_constraint"' }
          engine(:jruby).db(:postgresql) { 'Java::OrgPostgresqlUtil::PSQLException: ERROR: new row for relation "users" violates check constraint "comments_count_constraint"' }
        end

        repository = UserRepository.new
        user = repository.create(name: "L")

        expect { repository.update(user.id, comments_count: -2) }.to raise_error do |error|
          expect(error).to         be_a(expected)
          expect(error.message).to include(message)
        end
      end
    end
  end

  describe "#delete" do
    it "deletes record" do
      repository = UserRepository.new
      user = repository.create(name: "L")
      deleted = repository.delete(user.id)

      expect(deleted).to be_an_instance_of(User)
      expect(deleted.id).to eq(user.id)
      expect(deleted.name).to eq("L")

      found = repository.find(user.id)
      expect(found).to be_nil
    end

    it "returns nil when record cannot be found" do
      repository = UserRepository.new
      deleted = repository.delete("9999999")

      expect(deleted).to be_nil
    end
  end

  describe "#transaction" do
  end

  describe "custom finder" do
    it "returns records" do
      repository = UserRepository.new
      user = repository.create(name: "L")
      found = repository.by_name("L")

      expect(found.to_a).to include(user)
    end

    it "uses root relation" do
      repository = UserRepository.new
      user = repository.create(name: "L")
      found = repository.by_name_with_root("L")

      expect(found.to_a).to include(user)
    end

    it "selects only a single column" do
      repository = UserRepository.new
      repository.clear

      repository.create([{name: "L", age: 35}, {name: "MG", age: 34}])
      found = repository.ids

      expect(found.size).to be(2)
      found.each do |user|
        expect(user).to be_a_kind_of(User)
        expect(user.id).to_not be(nil)
        expect(user.name).to be(nil)
        expect(user.age).to be(nil)
      end
    end

    it "selects multiple columns" do
      repository = UserRepository.new
      repository.clear

      repository.create([{name: "L", age: 35}, {name: "MG", age: 34}])
      found = repository.select_id_and_name

      expect(found.size).to be(2)
      found.each do |user|
        expect(user).to be_a_kind_of(User)
        expect(user.id).to_not be(nil)
        expect(user.name).to_not be(nil)
        expect(user.age).to be(nil)
      end
    end
  end

  with_platform(db: :postgresql) do
    describe "PostgreSQL" do
      it "finds record by primary key (UUID)" do
        repository = SourceFileRepository.new
        file = repository.create(name: "path/to/file.rb", languages: ["ruby"], metadata: {coverage: 100.0}, content: "class Foo; end")
        found = repository.find(file.id)

        expect(file.languages).to eq(["ruby"])
        expect(file.metadata).to eq(coverage: 100.0)

        expect(found).to eq(file)
      end

      it "returns nil for nil primary key (UUID)" do
        repository = SourceFileRepository.new

        found = repository.find(nil)
        expect(found).to be_nil
      end

      # FIXME: This raises the following error
      #
      #   Sequel::DatabaseError: PG::InvalidTextRepresentation: ERROR:  invalid input syntax for uuid: "9999999"
      #   LINE 1: ...", "updated_at" FROM "source_files" WHERE ("id" = '9999999')...
      it "returns nil for missing record (UUID)"
      # it 'returns nil for missing record (UUID)' do
      #   repository = SourceFileRepository.new

      #   found = repository.find('9999999')
      #   expect(found).to be_nil
      # end

      describe "JSON types" do
        it "writes hashes" do
          hash = {first_name: "John", age: 53, married: true, car: nil}
          repository = SourceFileRepository.new
          column_type = repository.create(metadata: hash, name: "test", content: "test", json_info: hash)
          found = repository.find(column_type.id)

          expect(found.metadata).to eq(hash)
          expect(found.json_info).to eq(hash)
        end

        it "writes arrays" do
          array = ["abc", 1, true, nil]
          repository = SourceFileRepository.new
          column_type = repository.create(metadata: array, name: "test", content: "test", json_info: array)
          found = repository.find(column_type.id)

          expect(found.metadata).to eq(array)
          expect(found.json_info).to eq(array)
        end
      end

      describe "when timestamps aren't enabled" do
        it "writes the proper PG types" do
          repository = ProductRepository.new

          product = repository.create(name: "NeoVim", categories: ["software"])
          found = repository.find(product.id)

          expect(product.categories).to eq(["software"])

          expect(found).to eq(product)
        end

        it "succeeds even if timestamps is the only plugin" do
          repository = ProductRepository.new

          product = repository
            .command(:create, repository.root, use: %i[timestamps])
            .call(name: "NeoVim", categories: ["software"])

          found = repository.find(product.id)

          expect(product.categories).to eq(["software"])

          expect(found.to_h).to eq(product.to_h)
        end
      end
    end

    describe "enum database type" do
      it "allows to write data" do
        repository = ColorRepository.new
        color = repository.create(name: "red")

        expect(color).to be_a_kind_of(Color)
        expect(color.name).to eq("red")
      end

      it "raises error if the value is not included in the enum" do
        repository = ColorRepository.new
        message = Platform.match do
          engine(:ruby)  { %(PG::InvalidTextRepresentation: ERROR:  invalid input value for enum rainbow: "grey") }
          engine(:jruby) { %(Java::OrgPostgresqlUtil::PSQLException: ERROR: invalid input value for enum rainbow: "grey") }
        end

        expect { repository.create(name: "grey") }.to raise_error do |error|
          expect(error).to be_a(Hanami::Model::Error)
          expect(error.message).to include(message)
        end
      end
    end
  end
end
