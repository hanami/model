require 'test_helper'

describe 'Repository (legacy)' do
  describe '#find' do
    it 'finds record by primary key' do
      repository = OperatorRepository.new
      operator   = repository.create(name: 'F')
      found = repository.find(operator.id)

      operator.must_equal(found)
    end

    it 'returns nil for missing record' do
      repository = OperatorRepository.new
      found = repository.find('9999999')

      found.must_be_nil
    end
  end

  describe '#all' do
    it 'returns all the records' do
      repository = OperatorRepository.new
      operator = repository.create(name: 'F')

      repository.all.to_a.must_include operator
    end
  end

  describe '#first' do
    it 'returns first record from table' do
      repository = OperatorRepository.new
      repository.clear

      operator = repository.create(name: 'Janis Joplin')
      repository.create(name: 'Jon')

      repository.first.must_equal operator
    end
  end

  describe '#last' do
    it 'returns last record from table' do
      repository = OperatorRepository.new
      repository.clear

      repository.create(name: 'Rob')
      operator = repository.create(name: 'Amy Winehouse')

      repository.last.must_equal operator
    end
  end

  describe '#clear' do
    it 'clears all the records' do
      repository = OperatorRepository.new
      repository.create(name: 'F')

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
      repository = OperatorRepository.new
      operator = repository.create(name: 'F')

      operator.must_be_instance_of(Operator)
      operator.id.wont_be_nil
      operator.name.must_equal 'F'
    end
  end

  describe '#update' do
    it 'updates record' do
      repository = OperatorRepository.new
      operator   = repository.create(name: 'F')
      updated = repository.update(operator.id, name: 'Flo')

      updated.must_be_instance_of(Operator)
      updated.id.must_equal   operator.id
      updated.name.must_equal 'Flo'
    end

    it 'returns nil when record cannot be found' do
      repository = OperatorRepository.new
      updated = repository.update('9999999', name: 'Flo')

      updated.must_be_nil
    end
  end

  describe '#delete' do
    it 'deletes record' do
      repository = OperatorRepository.new
      operator   = repository.create(name: 'F')
      deleted = repository.delete(operator.id)

      deleted.must_be_instance_of(Operator)
      deleted.id.must_equal   operator.id
      deleted.name.must_equal 'F'

      found = repository.find(operator.id)
      found.must_be_nil
    end

    it 'returns nil when record cannot be found' do
      repository = OperatorRepository.new
      deleted = repository.delete('9999999')

      deleted.must_be_nil
    end
  end

  describe '#transaction' do
  end
end
