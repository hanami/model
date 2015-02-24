require 'test_helper'

describe Lotus::Model::Mapping::Coercer do
  let(:entity) { User.new(name: 'Tyrion Lannister') }
  let(:collection) { Lotus::Model::Mapping::Collection.new(:users, Lotus::Model::Mapping::Coercer) }
  let(:coercer) { Lotus::Model::Mapping::Coercer.new(collection) }

  before do
    collection.entity(User)
    collection.attribute :id,   Integer
    collection.attribute :name, String
    collection.attribute :age,  String
  end

  describe '#to_record' do
    it 'should not return identity column' do
      coercer.to_record(entity).must_equal(name: 'Tyrion Lannister')
    end

    # Bug:
    # https://github.com/lotus/model/issues/155
    it 'should not set keys for nil values when creating' do
      entity = User.new(name: 'Daenerys Targaryen', age: nil)
      coercer.to_record(entity).must_equal(name: 'Daenerys Targaryen')
    end

    it 'should set keys for nil values when updating' do
      entity = User.new(id: 4, name: 'Daenerys Targaryen', age: nil)
      coercer.to_record(entity).must_equal(id: 4, name: 'Daenerys Targaryen', age: nil)
    end

    describe 'when identity is set' do
      let(:entity) { User.new(id: 3, name: 'Tyrion Lannister') }

      it 'should return identity as well' do
        coercer.to_record(entity).must_equal(id: 3, name: 'Tyrion Lannister', age: nil)
      end
    end
  end
end
