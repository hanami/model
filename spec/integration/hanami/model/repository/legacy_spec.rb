RSpec.describe 'Repository (legacy)' do
  describe '#find' do
    it 'finds record by primary key' do
      repository = OperatorRepository.new
      operator = repository.create(name: 'F')
      found = repository.find(operator.id)

      expect(operator).to eq(found)
    end

    it 'returns nil for missing record' do
      repository = OperatorRepository.new
      found = repository.find('9999999')

      expect(found).to be_nil
    end
  end

  describe '#all' do
    it 'returns all the records' do
      repository = OperatorRepository.new
      operator = repository.create(name: 'F')

      expect(repository.all).to be_an_instance_of(Array)
      expect(repository.all).to include(operator)
    end
  end

  describe '#first' do
    it 'returns first record from table' do
      repository = OperatorRepository.new
      repository.clear

      operator = repository.create(name: 'Janis Joplin')
      repository.create(name: 'Jon')

      expect(repository.first).to eq(operator)
    end
  end

  describe '#last' do
    it 'returns last record from table' do
      repository = OperatorRepository.new
      repository.clear

      repository.create(name: 'Rob')
      operator = repository.create(name: 'Amy Winehouse')

      expect(repository.last).to eq(operator)
    end
  end

  describe '#clear' do
    it 'clears all the records' do
      repository = OperatorRepository.new
      repository.create(name: 'F')

      repository.clear
      expect(repository.all).to be_empty
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

      expect(operator).to be_an_instance_of(Operator)
      expect(operator.id).to_not be_nil
      expect(operator.name).to eq('F')
    end
  end

  describe '#update' do
    it 'updates record' do
      repository = OperatorRepository.new
      operator = repository.create(name: 'F')
      updated = repository.update(operator.id, name: 'Flo')

      expect(updated).to be_an_instance_of(Operator)
      expect(updated.id).to eq(operator.id)
      expect(updated.name).to eq('Flo')
    end

    it 'returns nil when record cannot be found' do
      repository = OperatorRepository.new
      updated = repository.update('9999999', name: 'Flo')

      expect(updated).to be_nil
    end
  end

  describe '#delete' do
    it 'deletes record' do
      repository = OperatorRepository.new
      operator = repository.create(name: 'F')
      deleted = repository.delete(operator.id)

      expect(deleted).to be_an_instance_of(Operator)
      expect(deleted.id).to eq(operator.id)
      expect(deleted.name).to eq('F')

      found = repository.find(operator.id)
      expect(found).to be_nil
    end

    it 'returns nil when record cannot be found' do
      repository = OperatorRepository.new
      deleted = repository.delete('9999999')

      expect(deleted).to be_nil
    end
  end

  describe '#transaction' do
  end
end
