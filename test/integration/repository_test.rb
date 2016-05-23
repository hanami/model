require 'test_helper'

describe 'Repository' do
  describe '#find' do
    it 'finds record by primary key' do
      repository = UserRepository.new
      user  = repository.create(name: 'L')
      found = repository.find(user.id)

      user.must_equal(found)
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

    it 'automatically touches timestamps'
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

      updated.must_be_instance_of(User)
      updated.id.must_be_nil
      updated.name.must_be_nil
    end

    it 'automatically touches timestamps'
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

      deleted.must_be_instance_of(User)
      deleted.id.must_be_nil
      deleted.name.must_be_nil
    end
  end

  describe 'custom finder' do
    it 'returns records' do
      repository = UserRepository.new
      user    = repository.create(name: 'L')
      found   = repository.by_name('L')

      found.to_a.must_include user
    end
  end

  describe 'associations' do
    it 'preloads associated records' do
      repository = UserRepository.new

      user    = repository.create(name: 'L')
      comment = CommentRepository.new.create(user_id: user.id, text: 'blah')

      found = repository.find_with_comments(user.id)

      found.must_equal user
      found.comments.map(&:to_h).must_equal [comment.to_h]
    end
  end
end
