require 'test_helper'

describe 'Repository (base)' do
  describe '#find' do
    it 'finds record by primary key' do
      repository = UserRepository.new
      user  = repository.create(name: 'L')
      found = repository.find(user.id)

      found.must_equal(user)
    end

    it 'returns nil for missing record' do
      repository = UserRepository.new
      found = repository.find('9999999')

      found.must_be_nil
    end
  end

  describe '#all' do
    it 'returns all the records' do
      repository = UserRepository.new
      user = repository.create(name: 'L')

      repository.all.to_a.must_include user
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
      repository.all.to_a.must_be :empty?
    end
  end

  describe '#execute' do
  end

  describe '#fetch' do
  end

  describe '#create' do
    it 'creates record' do
      repository = UserRepository.new
      user = repository.create(name: 'L')

      user.must_be_instance_of(User)
      user.id.wont_be_nil
      user.name.must_equal 'L'
    end

    if Database.engine?(:sqlite, :jruby)
      it 'automatically touches timestamps'
    else
      it 'automatically touches timestamps' do
        repository = UserRepository.new
        user = repository.create(name: 'L')

        user.created_at.must_be_close_to Time.now.utc, 0.9999999
        user.updated_at.must_be_close_to Time.now.utc, 0.9999999
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

    it 'raises error when generic database error is raised' do
      exception = -> { UserRepository.new.create(name: 'L', bogus: 23) }.must_raise(Hanami::Model::DatabaseError)
      message   = case Database.engine
                  when :sqlite
                    'SQLite3::SQLException: table users has no column named bogus'
                  when :postgresql
                    'PG::UndefinedColumn: ERROR:  column "bogus" of relation "users" does not exist'
                  when :mysql
                    "Mysql2::Error: Unknown column 'bogus' in 'field list'"
                  end

      exception.message.must_include message
    end

    it 'raises error when "not null" database constraint is violated' do
      exception = -> { UserRepository.new.create(name: 'L', active: nil) }.must_raise(Hanami::Model::NotNullConstraintViolationError)
      message   = case Database.engine
                  when :sqlite
                    'SQLite3::ConstraintException: NOT NULL constraint failed: users.active'
                  when :postgresql
                    'PG::NotNullViolation: ERROR:  null value in column "active" violates not-null constraint'
                  when :mysql
                    "Mysql2::Error: Column 'active' cannot be null"
                  end

      exception.message.must_include message
    end

    it 'raises error when "unique constraint" is violated' do
      repository = UserRepository.new
      repository.create(name: 'Test', email: email = "user@#{SecureRandom.uuid}.test")

      exception = -> { repository.create(name: 'L', email: email) }.must_raise(Hanami::Model::UniqueConstraintViolationError)
      message   = case Database.engine
                  when :sqlite
                    'SQLite3::ConstraintException: UNIQUE constraint failed: users.email'
                  when :postgresql
                    'PG::UniqueViolation: ERROR:  duplicate key value violates unique constraint "users_email_index"'
                  when :mysql
                    "Mysql2::Error: Duplicate entry '#{email}' for key 'users_email_index'"
                  end

      exception.message.must_include message
    end

    it 'raises error when "foreign key" constraint is violated' do
      exception = -> { AvatarRepository.new.create(user_id: 999_999_999) }.must_raise(Hanami::Model::ForeignKeyConstraintViolationError)
      message   = case Database.engine
                  when :sqlite
                    'SQLite3::ConstraintException: FOREIGN KEY constraint failed'
                  when :postgresql
                    'PG::ForeignKeyViolation: ERROR:  insert or update on table "avatars" violates foreign key constraint "avatars_user_id_fkey"'
                  when :mysql
                    'Mysql2::Error: Cannot add or update a child row: a foreign key constraint fails'
                  end

      exception.message.must_include message
    end

    # For MySQL [...] The CHECK clause is parsed but ignored by all storage engines.
    # http://dev.mysql.com/doc/refman/5.7/en/create-table.html
    unless Database.engine?(:mysql)
      it 'raises error when "check" constraint is violated' do
        exception = -> { UserRepository.new.create(name: 'L', age: 1) }.must_raise(Hanami::Model::CheckConstraintViolationError)
        message   = case Database.engine
                    when :sqlite
                      'SQLite3::ConstraintException: CHECK constraint failed: users'
                    when :postgresql
                      'PG::CheckViolation: ERROR:  new row for relation "users" violates check constraint "users_age_check"'
                    end

        exception.message.must_include message
      end

      it 'raises error when constraint is violated' do
        exception = -> { UserRepository.new.create(name: 'L', comments_count: -1) }.must_raise(Hanami::Model::CheckConstraintViolationError)
        message   = case Database.engine
                    when :sqlite
                      'SQLite3::ConstraintException: CHECK constraint failed: comments_count_constraint'
                    when :postgresql
                      'PG::CheckViolation: ERROR:  new row for relation "users" violates check constraint "comments_count_constraint"'
                    end

        exception.message.must_include message
      end
    end
  end

  describe '#update' do
    it 'updates record' do
      repository = UserRepository.new
      user    = repository.create(name: 'L')
      updated = repository.update(user.id, name: 'Luca')

      updated.must_be_instance_of(User)
      updated.id.must_equal   user.id
      updated.name.must_equal 'Luca'
    end

    it 'returns nil when record cannot be found' do
      repository = UserRepository.new
      updated = repository.update('9999999', name: 'Luca')

      updated.must_be_nil
    end

    if Database.engine?(:sqlite, :jruby)
      it 'automatically touches timestamps'
    else
      it 'automatically touches timestamps' do
        repository = UserRepository.new
        user = repository.create(name: 'L')
        sleep 0.1
        updated = repository.update(user.id, name: 'Luca')

        updated.created_at.must_be_close_to user.created_at, 0.99999999
        updated.updated_at.must_be_close_to Time.now.utc,    0.99999999
      end
    end

    it 'raises error when generic database error is raised' do
      repository = UserRepository.new
      user       = repository.create(name: 'L')

      exception = -> { repository.update(user.id, bogus: 23) }.must_raise(Hanami::Model::DatabaseError)
      message   = case Database.engine
                  when :sqlite
                    'SQLite3::SQLException: no such column: bogus'
                  when :postgresql
                    'PG::UndefinedColumn: ERROR:  column "bogus" of relation "users" does not exist'
                  when :mysql
                    "Mysql2::Error: Unknown column 'bogus' in 'field list'"
                  end

      exception.message.must_include message
    end

    it 'raises error when "not null" database constraint is violated' do
      repository = UserRepository.new
      user       = repository.create(name: 'L')

      exception = -> { repository.update(user.id, active: nil) }.must_raise(Hanami::Model::NotNullConstraintViolationError)
      message   = case Database.engine
                  when :sqlite
                    'SQLite3::ConstraintException: NOT NULL constraint failed: users.active'
                  when :postgresql
                    'PG::NotNullViolation: ERROR:  null value in column "active" violates not-null constraint'
                  when :mysql
                    "Mysql2::Error: Column 'active' cannot be null"
                  end

      exception.message.must_include message
    end

    it 'raises error when "unique constraint" is violated' do
      repository = UserRepository.new
      user       = repository.create(name: 'L')
      repository.create(name: 'UpdateTest', email: email = "update@#{SecureRandom.uuid}.test")

      exception = -> { repository.update(user.id, email: email) }.must_raise(Hanami::Model::UniqueConstraintViolationError)
      message   = case Database.engine
                  when :sqlite
                    'SQLite3::ConstraintException: UNIQUE constraint failed: users.email'
                  when :postgresql
                    'PG::UniqueViolation: ERROR:  duplicate key value violates unique constraint "users_email_index"'
                  when :mysql
                    "Mysql2::Error: Duplicate entry '#{email}' for key 'users_email_index'"
                  end

      exception.message.must_include message
    end

    it 'raises error when "foreign key" constraint is violated' do
      user       = UserRepository.new.create(name: 'L')
      repository = AvatarRepository.new
      avatar     = repository.create(user_id: user.id)

      exception = -> { repository.update(avatar.id, user_id: 999_999_999) }.must_raise(Hanami::Model::ForeignKeyConstraintViolationError)
      message   = case Database.engine
                  when :sqlite
                    'SQLite3::ConstraintException: FOREIGN KEY constraint failed'
                  when :postgresql
                    'PG::ForeignKeyViolation: ERROR:  insert or update on table "avatars" violates foreign key constraint "avatars_user_id_fkey"'
                  when :mysql
                    'Mysql2::Error: Cannot add or update a child row: a foreign key constraint fails'
                  end

      exception.message.must_include message
    end

    # For MySQL [...] The CHECK clause is parsed but ignored by all storage engines.
    # http://dev.mysql.com/doc/refman/5.7/en/create-table.html
    unless Database.engine?(:mysql)
      it 'raises error when "check" constraint is violated' do
        repository = UserRepository.new
        user       = repository.create(name: 'L')

        exception = -> { repository.update(user.id, age: 17) }.must_raise(Hanami::Model::CheckConstraintViolationError)
        message   = case Database.engine
                    when :sqlite
                      'SQLite3::ConstraintException: CHECK constraint failed: users'
                    when :postgresql
                      'PG::CheckViolation: ERROR:  new row for relation "users" violates check constraint "users_age_check"'
                    end

        exception.message.must_include message
      end

      it 'raises error when constraint is violated' do
        repository = UserRepository.new
        user       = repository.create(name: 'L')

        exception = -> { repository.update(user.id, comments_count: -2) }.must_raise(Hanami::Model::CheckConstraintViolationError)
        message   = case Database.engine
                    when :sqlite
                      'SQLite3::ConstraintException: CHECK constraint failed: comments_count_constraint'
                    when :postgresql
                      'PG::CheckViolation: ERROR:  new row for relation "users" violates check constraint "comments_count_constraint"'
                    end

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
  end

  if Database.engine?(:postgresql)
    describe 'PostgreSQL' do
      it 'finds record by primary key (UUID)' do
        repository = SourceFileRepository.new
        file  = repository.create(name: 'path/to/file.rb', languages: ['ruby'], metadata: { coverage: 100.0 }, content: 'class Foo; end')
        found = repository.find(file.id)

        file.languages.must_equal ['ruby']
        file.metadata.must_equal(coverage: 100.0)

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
    end
  end
end
