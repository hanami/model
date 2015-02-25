require 'test_helper'

describe Lotus::Model::Mapping::Coercer do
  let(:entity) { User.new(name: 'Tyrion Lannister') }
  let(:collection) { Lotus::Model::Mapping::Collection.new(:users, Lotus::Model::Mapping::Coercer) }
  let(:coercer) { Lotus::Model::Mapping::Coercer.new(collection) }

  before do
    collection.entity(User)
    collection.attribute :id,   Integer
    collection.attribute :name, String
  end

  describe '#to_record' do
    it 'should not return identity column' do
      coercer.to_record(entity).must_equal(name: 'Tyrion Lannister')
    end

    describe 'when identity is set' do
      let(:entity) { User.new(id: 3, name: 'Tyrion Lannister') }

      it 'should return identity as well' do
        coercer.to_record(entity).must_equal(id: 3, name: 'Tyrion Lannister')
      end
    end
  end
  
  describe '#from_record' do
    before do
      collection.entity(::Repository)
      collection.attribute :id,   Integer
      collection.attribute :name, String
    end
    
    it 'should use the correct entity class' do
      coercer.from_record(name: 'production').class.must_equal(::Repository)
    end
  end
end
