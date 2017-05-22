RSpec.describe Hanami::Entity::Schema do
  let(:described_class) { Hanami::Entity::Schema }

  describe 'without definition' do
    let(:subject) { described_class.new }

    describe '#call' do
      it 'processes attributes' do
        result = subject.call('foo' => 'bar')

        expect(result).to eq(foo: 'bar')
      end
    end

    describe '#attribute?' do
      it 'always returns true' do
        expect(subject.attribute?(:foo)).to eq true
      end
    end
  end

  describe 'with definition' do
    let(:subject) do
      described_class.new do
        attribute :id, Hanami::Model::Types::Coercible::Int
      end
    end

    describe '#call' do
      it 'processes attributes' do
        result = subject.call(id: '1')

        expect(result).to eq(id: 1)
      end

      it 'ignores unknown attributes' do
        result = subject.call(foo: 'bar')

        expect(result).to eq({})
      end
    end

    describe '#attribute?' do
      it 'returns true for known attributes' do
        expect(subject.attribute?(:id)).to eq true
      end

      it 'returns false for unknown attributes' do
        expect(subject.attribute?(:foo)).to eq false
      end
    end
  end
end
