require 'test_helper'
require 'securerandom'

describe 'Repository (base)' do
  extend PlatformHelpers

  describe '#find' do
    it 'finds record by primary key' do
      repository = UserRepository.new
      user  = repository.create(name: 'L')
      found = repository.find(user.id)

      found.must_equal(user)
    end

    it 'returns nil when nil is given' do
      repository = UserRepository.new
      repository.create(name: 'L')
      found = repository.find(nil)

      found.must_be_nil
    end

    it 'returns nil for missing record' do
      repository = UserRepository.new
      found = repository.find('9999999')

      found.must_be_nil
    end

    # See https://github.com/hanami/model/issues/374
    describe 'with non-autoincrement primary key' do
      before do
        repository.clear
      end

      let(:repository) { LabelRepository.new }
      let(:id)         { 1 }

      it 'raises error' do
        repository.create(id: id)

        exception = -> { repository.find(id) }.must_raise(Hanami::Model::MissingPrimaryKeyError)
        exception.message.must_equal "Missing primary key for :labels"
      end
    end
  end

  describe '#all' do
    it 'returns all the records' do
      repository = UserRepository.new
      user = repository.create(name: 'L')

      repository.all.must_be_instance_of Array
      repository.all.must_include user
    end
  end

  describe '#first' do
    it 'returns first record from table' do
      repository = UserRepository.new
      repository.clear

      user = repository.create(name: 'James Hetfield')
      repository.create(name: 'Tom')

      repository.first.must_equal user
    end
  end

  describe '#last' do
    it 'returns last record from table' do
      repository = UserRepository.new
      repository.clear

      repository.create(name: 'Tom')
      user = repository.create(name: 'Ella Fitzgerald')

      repository.last.must_equal user
    end
  end

  describe '#clear' do
    it 'clears all the records' do
      repository = UserRepository.new
      repository.create(name: 'L')

      repository.clear
      repository.all.must_be :empty?
    end
  end

  describe 'relation' do
    describe 'read' do
      it 'reads records from the database given a raw query string' do
        repository = UserRepository.new
        repository.create(name: 'L')

        users = repository.find_all_by_manual_query
        users.must_be_kind_of(Array)

        user = users.first
        user.must_be_kind_of(User)
      end
    end
  end

  describe '#create' do
    it 'creates record from data' do
      repository = UserRepository.new
      user = repository.create(name: 'L')

      user.must_be_instance_of(User)
      user.id.wont_be_nil
      user.name.must_equal 'L'
    end

    it 'creates record from entity' do
      entity     = User.new(name: 'L')
      repository = UserRepository.new
      user = repository.create(entity)

      # It doesn't mutate original entity
      entity.id.must_be_nil

      user.must_be_instance_of(User)
      user.id.wont_be_nil
      user.name.must_equal 'L'
    end

    with_platform(engine: :jruby, db: :sqlite) do
      it 'automatically touches timestamps'
    end

    unless_platform(engine: :jruby, db: :sqlite) do
      it 'automatically touches timestamps' do
        repository = UserRepository.new
        user = repository.create(name: 'L')

        user.created_at.must_be_close_to Time.now.utc, 2
        user.updated_at.must_be_close_to Time.now.utc, 2
      end

      it 'respects given timestamps' do
        repository = UserRepository.new
        given_time = Time.new(2010, 1, 1, 12, 0, 0, '+00:00')

        user = repository.create(name: 'L', created_at: given_time, updated_at: given_time)

        user.created_at.must_be_close_to given_time, 2
        user.updated_at.must_be_close_to given_time, 2
      end

      it 'can update timestamps' do
        repository = UserRepository.new
        user = repository.create(name: 'L')
        user.created_at.must_be_close_to Time.now.utc, 2
        user.updated_at.must_be_close_to Time.now.utc, 2

        given_time = Time.new(2010, 1, 1, 12, 0, 0, '+00:00')
        updated = repository.update(
          user.id,
          created_at: given_time,
          updated_at: given_time
        )

        updated.name.must_equal 'L'
        updated.created_at.must_be_close_to given_time, 2
        updated.updated_at.must_be_close_to given_time, 2
      end
    end

    # Bug: https://github.com/hanami/model/issues/237
    it 'respects database defaults' do
      repository = UserRepository.new
      user = repository.create(name: 'L')

      user.comments_count.must_equal 0
    end

    # Bug: https://github.com/hanami/model/issues/272
    it 'accepts booleans as attributes' do
      user = UserRepository.new.create(name: 'L', active: false)
      user.active.must_equal false
    end

    it 'raises error when generic database error is raised'
    # it 'raises error when generic database error is raised' do
    #   error   = Hanami::Model::DatabaseError
    #   message = Platform.match do
    #     engine(:ruby).db(:sqlite)  { 'SQLite3::SQLException: table users has no column named bogus' }
    #     engine(:jruby).db(:sqlite) { 'Java::JavaSql::SQLException: table users has no column named bogus' }

    #     engine(:ruby).db(:postgresql)  { 'PG::UndefinedColumn: ERROR:  column "bogus" of relation "users" does not exist' }
    #     engine(:jruby).db(:postgresql) { 'bogus' }

    #     engine(:ruby).db(:mysql)  { "Mysql2::Error: Unknown column 'bogus' in 'field list'" }
    #     engine(:jruby).db(:mysql) { 'bogus' }
    #   end

    #   exception = -> { UserRepository.new.create(name: 'L', bogus: 23) }.must_raise(error)
    #   exception.message.must_include message
    # end

    it 'raises error when "not null" database constraint is violated' do
      error   = Hanami::Model::NotNullConstraintViolationError
      message = Platform.match do
        engine(:ruby).db(:sqlite)  { 'SQLite3::ConstraintException' }
        engine(:jruby).db(:sqlite) { 'Java::OrgSqlite::SQLiteException: [SQLITE_CONSTRAINT_NOTNULL]  A NOT NULL constraint failed (NOT NULL constraint failed: users.active)' }

        engine(:ruby).db(:postgresql)  { 'PG::NotNullViolation: ERROR:  null value in column "active" violates not-null constraint' }
        engine(:jruby).db(:postgresql) { 'Java::OrgPostgresqlUtil::PSQLException: ERROR: null value in column "active" violates not-null constraint' }

        engine(:ruby).db(:mysql)  { "Mysql2::Error: Column 'active' cannot be null" }
        engine(:jruby).db(:mysql) { "Java::ComMysqlJdbcExceptionsJdbc4::MySQLIntegrityConstraintViolationException: Column 'active' cannot be null" }
      end

      exception = -> { UserRepository.new.create(name: 'L', active: nil) }.must_raise(error)
      exception.message.must_include message
    end

    it 'raises error when "unique constraint" is violated' do
      email = "user@#{SecureRandom.uuid}.test"

      error   = Hanami::Model::UniqueConstraintViolationError
      message = Platform.match do
        engine(:ruby).db(:sqlite)  { 'SQLite3::ConstraintException' }
        engine(:jruby).db(:sqlite) { 'Java::OrgSqlite::SQLiteException: [SQLITE_CONSTRAINT_UNIQUE]  A UNIQUE constraint failed (UNIQUE constraint failed: users.email)' }

        engine(:ruby).db(:postgresql)  { 'PG::UniqueViolation: ERROR:  duplicate key value violates unique constraint "users_email_index"' }
        engine(:jruby).db(:postgresql) { %(Java::OrgPostgresqlUtil::PSQLException: ERROR: duplicate key value violates unique constraint "users_email_index"\n  Detail: Key (email)=(#{email}) already exists.) }

        engine(:ruby).db(:mysql)  { "Mysql2::Error: Duplicate entry '#{email}' for key 'users_email_index'" }
        engine(:jruby).db(:mysql) { "Java::ComMysqlJdbcExceptionsJdbc4::MySQLIntegrityConstraintViolationException: Duplicate entry '#{email}' for key 'users_email_index'" }
      end

      repository = UserRepository.new
      repository.create(name: 'Test', email: email)

      exception = -> { repository.create(name: 'L', email: email) }.must_raise(error)
      exception.message.must_include message
    end

    it 'raises error when "foreign key" constraint is violated' do
      error   = Hanami::Model::ForeignKeyConstraintViolationError
      message = Platform.match do
        engine(:ruby).db(:sqlite)  { 'SQLite3::ConstraintException' }
        engine(:jruby).db(:sqlite) { 'Java::OrgSqlite::SQLiteException: [SQLITE_CONSTRAINT_FOREIGNKEY]  A foreign key constraint failed (FOREIGN KEY constraint failed)' }

        engine(:ruby).db(:postgresql)  { 'PG::ForeignKeyViolation: ERROR:  insert or update on table "avatars" violates foreign key constraint "avatars_user_id_fkey"' }
        engine(:jruby).db(:postgresql) { 'Java::OrgPostgresqlUtil::PSQLException: ERROR: insert or update on table "avatars" violates foreign key constraint "avatars_user_id_fkey"' }

        engine(:ruby).db(:mysql)  { 'Mysql2::Error: Cannot add or update a child row: a foreign key constraint fails' }
        engine(:jruby).db(:mysql) { 'Java::ComMysqlJdbcExceptionsJdbc4::MySQLIntegrityConstraintViolationException: Cannot add or update a child row: a foreign key constraint fails (`hanami_model`.`avatars`, CONSTRAINT `avatars_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE)' }
      end

      exception = -> { AvatarRepository.new.create(user_id: 999_999_999) }.must_raise(error)
      exception.message.must_include message
    end

    # For MySQL [...] The CHECK clause is parsed but ignored by all storage engines.
    # http://dev.mysql.com/doc/refman/5.7/en/create-table.html
    unless_platform(db: :mysql) do
      it 'raises error when "check" constraint is violated' do
        error = Platform.match do
          os(:linux).engine(:ruby).db(:sqlite) { Hanami::Model::ConstraintViolationError }
          default                              { Hanami::Model::CheckConstraintViolationError }
        end

        message = Platform.match do
          engine(:ruby).db(:sqlite)  { 'SQLite3::ConstraintException' }
          engine(:jruby).db(:sqlite) { 'Java::OrgSqlite::SQLiteException: [SQLITE_CONSTRAINT_CHECK]  A CHECK constraint failed (CHECK constraint failed: users)' }

          engine(:ruby).db(:postgresql)  { 'PG::CheckViolation: ERROR:  new row for relation "users" violates check constraint "users_age_check"' }
          engine(:jruby).db(:postgresql) { 'Java::OrgPostgresqlUtil::PSQLException: ERROR: new row for relation "users" violates check constraint "users_age_check"' }
        end

        exception = -> { UserRepository.new.create(name: 'L', age: 1) }.must_raise(error)
        exception.message.must_include message
      end

      it 'raises error when constraint is violated' do
        error = Platform.match do
          os(:linux).engine(:ruby).db(:sqlite) { Hanami::Model::ConstraintViolationError }
          default                              { Hanami::Model::CheckConstraintViolationError }
        end

        message = Platform.match do
          engine(:ruby).db(:sqlite)  { 'SQLite3::ConstraintException' }
          engine(:jruby).db(:sqlite) { 'Java::OrgSqlite::SQLiteException: [SQLITE_CONSTRAINT_CHECK]  A CHECK constraint failed (CHECK constraint failed: comments_count_constraint)' }

          engine(:ruby).db(:postgresql)  { 'PG::CheckViolation: ERROR:  new row for relation "users" violates check constraint "comments_count_constraint"' }
          engine(:jruby).db(:postgresql) { 'Java::OrgPostgresqlUtil::PSQLException: ERROR: new row for relation "users" violates check constraint "comments_count_constraint"' }
        end

        exception = -> { UserRepository.new.create(name: 'L', comments_count: -1) }.must_raise(error)
        exception.message.must_include message
      end
    end
  end

  describe '#update' do
    it 'updates record from data' do
      repository = UserRepository.new
      user    = repository.create(name: 'L')
      updated = repository.update(user.id, name: 'Luca')

      updated.must_be_instance_of(User)
      updated.id.must_equal   user.id
      updated.name.must_equal 'Luca'
    end

    it 'updates record from entity' do
      entity     = User.new(name: 'Luca')
      repository = UserRepository.new
      user       = repository.create(name: 'L')
      updated    = repository.update(user.id, entity)

      # It doesn't mutate original entity
      entity.id.must_be_nil

      updated.must_be_instance_of(User)
      updated.id.must_equal   user.id
      updated.name.must_equal 'Luca'
    end

    it 'returns nil when record cannot be found' do
      repository = UserRepository.new
      updated = repository.update('9999999', name: 'Luca')

      updated.must_be_nil
    end

    with_platform(engine: :jruby, db: :sqlite) do
      it 'automatically touches timestamps'
    end

    unless_platform(engine: :jruby, db: :sqlite) do
      it 'automatically touches timestamps' do
        repository = UserRepository.new
        user = repository.create(name: 'L')
        sleep 0.1
        updated = repository.update(user.id, name: 'Luca')

        updated.created_at.must_be_close_to user.created_at, 2
        updated.updated_at.must_be_close_to Time.now,        2
      end
    end

    it 'raises error when generic database error is raised'
    # it 'raises error when generic database error is raised' do
    #   error   = Hanami::Model::DatabaseError
    #   message = Platform.match do
    #     engine(:ruby).db(:sqlite)  { 'SQLite3::SQLException: no such column: bogus' }
    #     engine(:jruby).db(:sqlite) { 'Java::JavaSql::SQLException: no such column: bogus' }

    #     engine(:ruby).db(:postgresql)  { 'PG::UndefinedColumn: ERROR:  column "bogus" of relation "users" does not exist' }
    #     engine(:jruby).db(:postgresql) { 'bogus' }

    #     engine(:ruby).db(:mysql)  { "Mysql2::Error: Unknown column 'bogus' in 'field list'" }
    #     engine(:jruby).db(:mysql) { 'bogus' }
    #   end

    #   repository = UserRepository.new
    #   user       = repository.create(name: 'L')

    #   exception = -> { repository.update(user.id, bogus: 23) }.must_raise(error)
    #   exception.message.must_include message
    # end

    # MySQL doesn't raise an error on CI
    unless_platform(os: :linux, engine: :ruby, db: :mysql) do
      it 'raises error when "not null" database constraint is violated' do
        error   = Hanami::Model::NotNullConstraintViolationError
        message = Platform.match do
          engine(:ruby).db(:sqlite)  { 'SQLite3::ConstraintException' }
          engine(:jruby).db(:sqlite) { 'Java::OrgSqlite::SQLiteException: [SQLITE_CONSTRAINT_NOTNULL]  A NOT NULL constraint failed (NOT NULL constraint failed: users.active)' }

          engine(:ruby).db(:postgresql)  { 'PG::NotNullViolation: ERROR:  null value in column "active" violates not-null constraint' }
          engine(:jruby).db(:postgresql) { 'Java::OrgPostgresqlUtil::PSQLException: ERROR: null value in column "active" violates not-null constraint' }

          engine(:ruby).db(:mysql)  { "Mysql2::Error: Column 'active' cannot be null" }
          engine(:jruby).db(:mysql) { "Java::ComMysqlJdbcExceptionsJdbc4::MySQLIntegrityConstraintViolationException: Column 'active' cannot be null" }
        end

        repository = UserRepository.new
        user       = repository.create(name: 'L')

        exception = -> { repository.update(user.id, active: nil) }.must_raise(error)
        exception.message.must_include message
      end
    end

    it 'raises error when "unique constraint" is violated' do
      email = "update@#{SecureRandom.uuid}.test"

      error   = Hanami::Model::UniqueConstraintViolationError
      message = Platform.match do
        engine(:ruby).db(:sqlite)  { 'SQLite3::ConstraintException' }
        engine(:jruby).db(:sqlite) { 'Java::OrgSqlite::SQLiteException: [SQLITE_CONSTRAINT_UNIQUE]  A UNIQUE constraint failed (UNIQUE constraint failed: users.email)' }

        engine(:ruby).db(:postgresql)  { 'PG::UniqueViolation: ERROR:  duplicate key value violates unique constraint "users_email_index"' }
        engine(:jruby).db(:postgresql) { 'Java::OrgPostgresqlUtil::PSQLException: ERROR: duplicate key value violates unique constraint "users_email_index"' }

        engine(:ruby).db(:mysql)  { "Mysql2::Error: Duplicate entry '#{email}' for key 'users_email_index'" }
        engine(:jruby).db(:mysql) { "Java::ComMysqlJdbcExceptionsJdbc4::MySQLIntegrityConstraintViolationException: Duplicate entry '#{email}' for key 'users_email_index'" }
      end

      repository = UserRepository.new
      user       = repository.create(name: 'L')
      repository.create(name: 'UpdateTest', email: email)

      exception = -> { repository.update(user.id, email: email) }.must_raise(error)
      exception.message.must_include message
    end

    it 'raises error when "foreign key" constraint is violated' do
      error   = Hanami::Model::ForeignKeyConstraintViolationError
      message = Platform.match do
        engine(:ruby).db(:sqlite)  { 'SQLite3::ConstraintException' }
        engine(:jruby).db(:sqlite) { 'Java::OrgSqlite::SQLiteException: [SQLITE_CONSTRAINT_FOREIGNKEY]  A foreign key constraint failed (FOREIGN KEY constraint failed)' }

        engine(:ruby).db(:postgresql)  { 'PG::ForeignKeyViolation: ERROR:  insert or update on table "avatars" violates foreign key constraint "avatars_user_id_fkey"' }
        engine(:jruby).db(:postgresql) { 'Java::OrgPostgresqlUtil::PSQLException: ERROR: insert or update on table "avatars" violates foreign key constraint "avatars_user_id_fkey"' }

        engine(:ruby).db(:mysql)  { 'Mysql2::Error: Cannot add or update a child row: a foreign key constraint fails' }
        engine(:jruby).db(:mysql) { 'Java::ComMysqlJdbcExceptionsJdbc4::MySQLIntegrityConstraintViolationException: Cannot add or update a child row: a foreign key constraint fails (`hanami_model`.`avatars`, CONSTRAINT `avatars_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE)' }
      end

      user       = UserRepository.new.create(name: 'L')
      repository = AvatarRepository.new
      avatar     = repository.create(user_id: user.id)

      exception = -> { repository.update(avatar.id, user_id: 999_999_999) }.must_raise(error)
      exception.message.must_include message
    end

    # For MySQL [...] The CHECK clause is parsed but ignored by all storage engines.
    # http://dev.mysql.com/doc/refman/5.7/en/create-table.html
    unless_platform(db: :mysql) do
      it 'raises error when "check" constraint is violated' do
        error = Platform.match do
          os(:linux).engine(:ruby).db(:sqlite) { Hanami::Model::ConstraintViolationError }
          default                              { Hanami::Model::CheckConstraintViolationError }
        end

        message = Platform.match do
          engine(:ruby).db(:sqlite)   { 'SQLite3::ConstraintException' }
          engine(:jruby).db(:sqlite)  { 'Java::OrgSqlite::SQLiteException: [SQLITE_CONSTRAINT_CHECK]  A CHECK constraint failed (CHECK constraint failed: users)' }

          engine(:ruby).db(:postgresql)  { 'PG::CheckViolation: ERROR:  new row for relation "users" violates check constraint "users_age_check"' }
          engine(:jruby).db(:postgresql) { 'Java::OrgPostgresqlUtil::PSQLException: ERROR: new row for relation "users" violates check constraint "users_age_check"' }
        end

        repository = UserRepository.new
        user       = repository.create(name: 'L')

        exception = -> { repository.update(user.id, age: 17) }.must_raise(error)
        exception.message.must_include message
      end

      it 'raises error when constraint is violated' do
        error = Platform.match do
          os(:linux).engine(:ruby).db(:sqlite) { Hanami::Model::ConstraintViolationError }
          default                              { Hanami::Model::CheckConstraintViolationError }
        end

        message = Platform.match do
          engine(:ruby).db(:sqlite)   { 'SQLite3::ConstraintException' }
          engine(:jruby).db(:sqlite)  { 'Java::OrgSqlite::SQLiteException: [SQLITE_CONSTRAINT_CHECK]  A CHECK constraint failed (CHECK constraint failed: comments_count_constraint)' }

          engine(:ruby).db(:postgresql)  { 'PG::CheckViolation: ERROR:  new row for relation "users" violates check constraint "comments_count_constraint"' }
          engine(:jruby).db(:postgresql) { 'Java::OrgPostgresqlUtil::PSQLException: ERROR: new row for relation "users" violates check constraint "comments_count_constraint"' }
        end

        repository = UserRepository.new
        user       = repository.create(name: 'L')

        exception = -> { repository.update(user.id, comments_count: -2) }.must_raise(error)
        exception.message.must_include message
      end
    end
  end

  describe '#delete' do
    it 'deletes record' do
      repository = UserRepository.new
      user    = repository.create(name: 'L')
      deleted = repository.delete(user.id)

      deleted.must_be_instance_of(User)
      deleted.id.must_equal   user.id
      deleted.name.must_equal 'L'

      found = repository.find(user.id)
      found.must_be_nil
    end

    it 'returns nil when record cannot be found' do
      repository = UserRepository.new
      deleted = repository.delete('9999999')

      deleted.must_be_nil
    end
  end

  describe '#transaction' do
  end

  describe 'custom finder' do
    it 'returns records' do
      repository = UserRepository.new
      user    = repository.create(name: 'L')
      found   = repository.by_name('L')

      found.to_a.must_include user
    end

    it 'uses root relation' do
      repository = UserRepository.new
      user    = repository.create(name: 'L')
      found   = repository.by_name_with_root('L')

      found.to_a.must_include user
    end
  end

  with_platform(db: :postgresql) do
    describe 'PostgreSQL' do
      it 'finds record by primary key (UUID)' do
        repository = SourceFileRepository.new
        file  = repository.create(name: 'path/to/file.rb', languages: ['ruby'], metadata: { coverage: 100.0 }, content: 'class Foo; end')
        found = repository.find(file.id)

        file.languages.must_equal ['ruby']
        file.metadata.must_equal('coverage' => 100.0)

        found.must_equal(file)
      end

      it 'returns nil for nil primary key (UUID)' do
        repository = SourceFileRepository.new

        found = repository.find(nil)
        found.must_be_nil
      end

      # FIXME: This raises the following error
      #
      #   Sequel::DatabaseError: PG::InvalidTextRepresentation: ERROR:  invalid input syntax for uuid: "9999999"
      #   LINE 1: ...", "updated_at" FROM "source_files" WHERE ("id" = '9999999')...
      it 'returns nil for missing record (UUID)'
      # it 'returns nil for missing record (UUID)' do
      #   repository = SourceFileRepository.new

      #   found = repository.find('9999999')
      #   found.must_be_nil
      # end
      describe "when timestamps aren't enabled" do
        it 'writes the proper PG types' do
          repository = ProductRepository.new

          product = repository.create(name: 'NeoVim', categories: ['software'])
          found   = repository.find(product.id)

          product.categories.must_equal(['software'])

          found.must_equal(product)
        end
      end
    end

    describe 'enum database type' do
      it 'allows to write data' do
        repository = ColorRepository.new
        color = repository.create(name: 'red')

        color.must_be_kind_of(Color)
        color.name.must_equal 'red'
      end

      it 'raises error if the value is not included in the enum' do
        repository = ColorRepository.new
        message    = Platform.match do
          engine(:ruby)  { %(PG::InvalidTextRepresentation: ERROR:  invalid input value for enum rainbow: "grey") }
          engine(:jruby) { %(Java::OrgPostgresqlUtil::PSQLException: ERROR: invalid input value for enum rainbow: "grey") }
        end

        exception = -> { repository.create(name: 'grey') }.must_raise(Hanami::Model::Error)
        exception.message.must_include message
      end
    end
  end
end
