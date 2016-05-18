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
      found = repository.find('unknown')

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
  end

  describe '#last' do
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

    it 'returns nil when record cannot be found'
    # it 'returns nil when record cannot be found' do
    #   repository = UserRepository.new
    #   updated = repository.update('unknown', name: 'Luca')

    #   updated.must_be_instance_of(User)
    #   updated.id.must_be_nil
    #   updated.name.must_be_nil
    # end

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

    it 'returns nil when record cannot be found'
    # it 'returns nil when record cannot be found' do
    #   repository = UserRepository.new
    #   deleted = repository.delete('unknown')

    #   deleted.must_be_instance_of(User)
    #   deleted.id.must_be_nil
    #   deleted.name.must_be_nil
    # end
  end

#   describe 'custom finder' do
#     it 'returns records' do
#       repository = UserRepository.new
#       user    = repository.create(name: 'L')
#       found   = repository.by_name('L')

#       found.to_a.must_include user
#     end
#   end
  describe 'associations' do
    it 'preloads associated records' do
      repository = UserRepository.new

      user    = repository.create(name: 'L')
      comment = CommentRepository.new.create(user_id: user.id, text: 'blah')

      found = repository.find_with_comments(user.id)

      found.must_equal user
      found.comments.must_equal [comment]
    end
  end
end
