require 'test_helper'

describe Lotus::Model::Mapping::Collection do
  before do
    @collection = Lotus::Model::Mapping::Collection.new(:users, Lotus::Model::Mapping::Coercer)
  end

  describe '::Boolean' do
    it 'defines top level constant' do
      assert defined?(::Boolean)
    end
  end

  describe '#initialize' do
    it 'assigns the name' do
      @collection.name.must_equal :users
    end

    it 'assigns the coercer class' do
      @collection.coercer_class.must_equal Lotus::Model::Mapping::Coercer
    end

    it 'executes the given block' do
      collection = Lotus::Model::Mapping::Collection.new(:users, Lotus::Model::Mapping::Coercer) do
        entity User
      end

      collection.entity.must_equal User
    end
  end

  describe '#entity' do
    describe 'when a value is given' do
      describe 'when the value is a class' do
        before do
          @collection.entity(User)
        end

        it 'sets the value' do
          @collection.entity.must_equal User
        end
      end

      describe 'when the value is a string' do
        before do
          @collection.entity('User')
        end

        it 'sets the value and classify the value' do
          @collection.entity.must_equal User
        end
      end
    end

    describe 'when a value is not given' do
      it 'returns the value' do
        @collection.entity.must_be_nil
      end
    end
  end

  describe '#repository' do
    before do
      @collection.entity User
    end

    describe 'when a value is given' do
      describe 'when the value is a class' do
        before do
          @collection.repository(CustomUserRepository)
        end

        it 'sets the value' do
          @collection.repository.must_equal CustomUserRepository
        end
      end

      describe 'when the value is a string' do
        before do
          @collection.repository('CustomUserRepository')
        end

        it 'sets the value and classify the value' do
          @collection.repository.must_equal CustomUserRepository
        end
      end
    end

    describe 'when a value is not given' do
      it 'returns the default value' do
        @collection.repository.must_equal UserRepository
      end

      describe 'when repository class is not found' do
        before do
          class KlassWithoutRepository; end
          @collection.entity KlassWithoutRepository
        end

        it 'raises NameError' do
          -> { @collection.repository }.must_raise NameError
        end
      end
    end
  end

  describe '#identity' do
    describe 'when a value is given' do
      before do
        @collection.identity(:_id)
      end

      it 'sets the value' do
        @collection.identity.must_equal :_id
      end
    end

    describe 'when a value is not given' do
      it 'returns the value' do
        @collection.identity.must_equal(:id)
      end
    end
  end

  describe '#attribute' do
    before do
      @collection.attribute :id,   Integer
      @collection.attribute :name, String, as: 't_name'
    end

    it 'defines an attribute' do
      @collection.attributes[:id].must_equal [Integer, :id]
    end

    it 'defines a mapped attribute' do
      @collection.attributes[:name].must_equal [String, :t_name]
    end
  end

  describe '#load!' do
    before do
      @adapter = Lotus::Model::Adapters::SqlAdapter.new(nil, SQLITE_CONNECTION_STRING)
      @collection.entity(User)
      @collection.adapter = @adapter
      @collection.load!
    end

    it 'sets up repository' do
      UserRepository.collection.must_equal :users
      UserRepository.instance_variable_get(:@adapter).must_equal @adapter
    end

    it 'instantiates coercer' do
      @collection.instance_variable_get(:@coercer).must_be_instance_of Lotus::Model::Mapping::Coercer
    end
  end
end
