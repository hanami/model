require 'test_helper'

describe Hanami::Model::Adapters::SqlAdapter do
  before do
    class TestUser
      include Hanami::Entity

      attributes :country_id, :name, :age
    end

    class TestUserRepository
      include Hanami::Repository
    end

    class TestDevice
      include Hanami::Entity

      attributes :u_id
    end

    class TestDeviceRepository
      include Hanami::Repository
    end

    class TestOrder
      include Hanami::Entity

      attributes :user_id, :total
    end

    class TestOrderRepository
      include Hanami::Repository
    end

    class TestAge
      include Hanami::Entity

      attributes :value, :label
    end

    class TestAgeRepository
      include Hanami::Repository
    end

    class TestCountry
      include Hanami::Entity

      attributes :code, :country_id
    end

    class TestCountryRepository
      include Hanami::Repository
    end

    @mapper = Hanami::Model::Mapper.new do
      collection :users do
        entity TestUser

        attribute :id,   Integer
        attribute :country_id, Integer
        attribute :name, String
        attribute :age,  Integer
      end

      collection :devices do
        entity TestDevice

        attribute :id, Integer
        attribute :u_id, Integer
      end

      collection :orders do
        entity TestOrder

        attribute :id,      Integer
        attribute :user_id, Integer
        attribute :total,   Integer
      end

      collection :ages do
        entity TestAge

        attribute :id,    Integer
        attribute :value, Integer
        attribute :label, String
      end

      collection :countries do
        entity TestCountry

        identity :country_id
        attribute :id,   Integer, as: :country_id
        attribute :code, String
      end
    end.load!

    @adapter = Hanami::Model::Adapters::SqlAdapter.new(@mapper, SQLITE_CONNECTION_STRING)
    @adapter.clear(collection)
  end

  after do
    Object.send(:remove_const, :TestUser)
    Object.send(:remove_const, :TestUserRepository)
    Object.send(:remove_const, :TestDevice)
    Object.send(:remove_const, :TestDeviceRepository)
    Object.send(:remove_const, :TestOrder)
    Object.send(:remove_const, :TestOrderRepository)
    Object.send(:remove_const, :TestAge)
    Object.send(:remove_const, :TestAgeRepository)
    Object.send(:remove_const, :TestCountry)
    Object.send(:remove_const, :TestCountryRepository)
  end

  let(:collection) { :users }

  describe 'multiple collections' do
    before do
      @adapter.clear(:devices)
    end

    it 'create records' do
      user   = TestUser.new
      device = TestDevice.new

      user   = @adapter.create(:users, user.to_h)
      device = @adapter.create(:devices, device.to_h)

      @adapter.all(:users).must_equal   [user]
      @adapter.all(:devices).must_equal [device]
    end
  end

  describe '#initialize' do
    it 'raises an error when the given URI refers to a non registered database adapter' do
      -> {
        Hanami::Model::Adapters::SqlAdapter.new(@mapper, 'oracle://host')
      }.must_raise(Hanami::Model::Adapters::DatabaseAdapterNotFound)
    end

    it 'raises an error when the given URI refers to an unknown database adapter' do
      -> {
        Hanami::Model::Adapters::SqlAdapter.new(@mapper, 'unknown://host')
      }.must_raise(Hanami::Model::Adapters::DatabaseAdapterNotFound)
    end

    it 'raises an error when the given URI is malformed' do
      -> {
        Hanami::Model::Adapters::SqlAdapter.new(@mapper, 'unknown_db:host')
      }.must_raise(URI::InvalidURIError)
    end

    it 'supports non-mandatory adapter configurations' do
      spy = nil
      after_connect_spy_proc = Proc.new { spy = true }

      adapter = Hanami::Model::Adapters::SqlAdapter.new(@mapper,
                                                        SQLITE_CONNECTION_STRING, after_connect: after_connect_spy_proc)

      # Sequel lazily connects
      adapter.execute('select 1 as dummy')

      spy.must_equal true
    end

  end

  describe '#persist' do
    describe 'when the given entity is not persisted' do
      let(:entity) { TestUser.new }

      it 'stores the record and assigns an id with entity' do
        result = @adapter.persist(collection, entity.to_h)

        result.id.wont_be_nil
        @adapter.find(collection, result.id).must_equal result
      end
    end

    describe 'when the given entity is persisted' do
      before do
        @entity = @adapter.create(collection, entity.to_h)
      end

      let(:entity) { TestUser.new }

      it 'updates the record and leaves untouched the id' do
        id = @entity.id
        id.wont_be_nil
        @entity.name = 'L'

        result = @adapter.persist(collection, @entity.to_h)

        result.id.must_equal(id)
        @adapter.find(collection, result.id).name.must_equal @entity.name
      end
    end
  end

  describe '#create' do
    let(:entity) { TestUser.new }

    it 'stores the record and assigns an id with entity' do
      result = @adapter.create(collection, entity.to_h)

      result.id.wont_be_nil
      @adapter.find(collection, result.id).must_equal result
    end
  end

  describe '#update' do
    before do
      @entity = @adapter.create(collection, entity.to_h)
    end

    let(:entity) { TestUser.new(id: nil, name: 'L') }

    it 'stores the changes and leave the id untouched' do
      id = @entity.id
      @entity.name = 'MG'

      result = @adapter.update(collection, @entity.to_h)

      result.id.must_equal id
      @adapter.find(collection, result.id).name.must_equal @entity.name
    end
  end

  describe '#delete' do
    before do
      @adapter.create(collection, entity.to_h)
    end

    let(:entity) { TestUser.new }

    it 'removes the given identity' do
      @adapter.delete(collection, entity.to_h)
      @adapter.find(collection, entity.id).must_be_nil
    end
  end

  describe '#all' do
    describe 'when no records are persisted' do
      before do
        @adapter.clear(collection)
      end

      it 'returns an empty collection' do
        @adapter.all(collection).must_be_empty
      end
    end

    describe 'when some records are persisted' do
      before do
        @entity = @adapter.create(collection, entity.to_h)
      end

      let(:entity) { TestUser.new }

      it 'returns all of them' do
        @adapter.all(collection).must_equal [@entity]
      end
    end
  end

  describe '#find' do
    before do
      @entity = @adapter.create(collection, entity.to_h)
    end

    let(:entity) { TestUser.new }

    it 'returns the record by id' do
      @adapter.find(collection, @entity.id).must_equal @entity
    end

    it 'returns nil when the record cannot be found' do
      @adapter.find(collection, 1_000_000).must_be_nil
    end

    it 'returns nil when the given id is nil' do
      @adapter.find(collection, nil).must_be_nil
    end
  end

  describe '#first' do
    describe 'when no records are peristed' do
      before do
        @adapter.clear(collection)
      end

      it 'returns nil' do
        @adapter.first(collection).must_be_nil
      end
    end

    describe 'when some records are persisted' do
      before do
        @entity1 = @adapter.create(collection, entity1.to_h)
        @entity2 = @adapter.create(collection, entity2.to_h)
      end

      let(:entity1) { TestUser.new }
      let(:entity2) { TestUser.new }

      it 'returns the first record' do
        @adapter.first(collection).must_equal @entity1
      end
    end
  end

  describe '#last' do
    describe 'when no records are peristed' do
      before do
        @adapter.clear(collection)
      end

      it 'returns nil' do
        @adapter.last(collection).must_be_nil
      end
    end

    describe 'when some records are persisted' do
      before do
        @entity1 = @adapter.create(collection, entity1.to_h)
        @entity2 = @adapter.create(collection, entity2.to_h)
      end

      let(:entity1) { TestUser.new }
      let(:entity2) { TestUser.new }

      it 'returns the last record' do
        @adapter.last(collection).must_equal @entity2
      end
    end
  end

  describe '#clear' do
    before do
      @adapter.create(collection, entity.to_h)
    end

    let(:entity) { TestUser.new }

    it 'removes all the records' do
      @adapter.clear(collection)
      @adapter.all(collection).must_be_empty
    end
  end

  describe '#query' do
    before do
      @adapter.clear(collection)
    end

    let(:user1) { TestUser.new(name: 'L',  age: '32') }
    let(:user2) { TestUser.new(name: 'MG', age: 31)   }
    let(:user3) { TestUser.new(name: 'S',  age: 2)    }

    describe 'where' do
      describe 'with an empty collection' do
        it 'returns an empty result set' do
          result = @adapter.query(collection) do
            where(id: 23)
          end.all

          result.must_be_empty
        end
      end

      describe 'with a filled collection' do
        before do
          @user1 = @adapter.create(collection, user1.to_h)
          @user2 = @adapter.create(collection, user2.to_h)
        end

        it 'returns selected records' do
          id = @user1.id

          query = Proc.new {
            where(id: id)
          }

          result = @adapter.query(collection, &query).all
          result.must_equal [@user1]
        end

        it 'can use multiple where conditions' do
          id   = @user1.id
          name = @user1.name

          query = Proc.new {
            where(id: id).where(name: name)
          }

          result = @adapter.query(collection, &query).all
          result.must_equal [@user1]
        end

        it 'can use multiple where conditions with "and" alias' do
          id   = @user1.id
          name = @user1.name

          query = Proc.new {
            where(id: id).and(name: name)
          }

          result = @adapter.query(collection, &query).all
          result.must_equal [@user1]
        end

        it 'can use lambda to describe where conditions' do
          query = Proc.new {
            where{ age > 31 }
          }

          result = @adapter.query(collection, &query).all
          result.must_equal [@user1]
        end

        it 'raises InvalidQueryError if you use wrong column names' do
          exception = -> {
            query = Proc.new { where { a > 31 } }
            @adapter.query(collection, &query).all
          }.must_raise(Hanami::Model::InvalidQueryError)

          exception.message.wont_be_nil
        end

        it 'raises an error if you dont specify condition or block' do
          -> {
            query = Proc.new {
              where()
            }
            @adapter.query(collection, &query).all
          }.must_raise(ArgumentError)
        end
      end
    end

    describe 'exclude' do
      describe 'with an empty collection' do
        it 'returns an empty result set' do
          result = @adapter.query(collection) do
            exclude(id: 23)
          end.all

          result.must_be_empty
        end
      end

      describe 'with a filled collection' do
        before do
          @user1 = @adapter.create(collection, user1.to_h)
          @user2 = @adapter.create(collection, user2.to_h)
          @user3 = @adapter.create(collection, user3.to_h)
        end

        let(:user3) { TestUser.new(name: 'S', age: 2) }

        it 'returns selected records' do
          id = @user1.id

          query = Proc.new {
            exclude(id: id)
          }

          result = @adapter.query(collection, &query).all
          result.must_equal [@user2, @user3]
        end

        it 'can use multiple exclude conditions' do
          id   = @user1.id
          name = @user2.name

          query = Proc.new {
            exclude(id: id).exclude(name: name)
          }

          result = @adapter.query(collection, &query).all
          result.must_equal [@user3]
        end

        it 'can use multiple exclude conditions with "not" alias' do
          id   = @user1.id
          name = @user2.name

          query = Proc.new {
            self.not(id: id).not(name: name)
          }

          result = @adapter.query(collection, &query).all
          result.must_equal [@user3]
        end

        it 'raises InvalidQueryError if you use wrong column names' do
          exception = -> {
            query = Proc.new { exclude{ a > 32 } }
            @adapter.query(collection, &query).all
          }.must_raise(Hanami::Model::InvalidQueryError)

          exception.message.wont_be_nil
        end

        it 'can use lambda to describe exclude conditions' do
          query = Proc.new {
            exclude{ age > 31 }
          }

          result = @adapter.query(collection, &query).all
          result.must_equal [@user2, @user3]
        end

        it 'raises an error if you dont specify condition or block' do
          -> {
            query = Proc.new {
              exclude()
            }
            @adapter.query(collection, &query).all
          }.must_raise(ArgumentError)
        end
      end
    end

    describe 'or' do
      describe 'with an empty collection' do
        it 'returns an empty result set' do
          result = @adapter.query(collection) do
            where(name: 'L').or(name: 'MG')
          end.all

          result.must_be_empty
        end
      end

      describe 'with a filled collection' do
        before do
          @user1 = @adapter.create(collection, user1.to_h)
          @user2 = @adapter.create(collection, user2.to_h)
        end

        it 'returns selected records' do
          name1 = @user1.name
          name2 = @user2.name

          query = Proc.new {
            where(name: name1).or(name: name2)
          }

          result = @adapter.query(collection, &query).all
          result.must_equal [@user1, @user2]
        end

        it 'can use lambda to describe or conditions' do
          name1 = @user1.name

          query = Proc.new {
            where(name: name1).or{ age < 32 }
          }

          result = @adapter.query(collection, &query).all
          result.must_equal [@user1, @user2]
        end

        it 'raises an error if you dont specify condition or block' do
          -> {
            name1 = @user1.name

            query = Proc.new {
              where(name: name1).or()
            }
            @adapter.query(collection, &query).all
          }.must_raise(ArgumentError)
        end

        it 'raises InvalidQueryError if you use wrong column names' do
          exception = -> {
            name1 = @user1.name
            name2 = @user2.name
            query = Proc.new { where(name: name1).or(n: name2) }

            @adapter.query(collection, &query).all
          }.must_raise(Hanami::Model::InvalidQueryError)

          exception.message.wont_be_nil
        end
      end
    end

    describe 'select' do
      describe 'with an empty collection' do
        it 'returns an empty result' do
          result = @adapter.query(collection) do
            select(:age)
          end.all

          result.must_be_empty
        end
      end

      describe 'with a filled collection' do
        before do
          @adapter.create(collection, user1.to_h)
          @adapter.create(collection, user2.to_h)
          @adapter.create(collection, user3.to_h)
        end

        let(:user1) { TestUser.new(name: 'L', age: 32) }
        let(:user3) { TestUser.new(name: 'S') }
        let(:users) { [user1, user2, user3] }

        it 'returns the selected columnts from all the records' do
          query = Proc.new {
            select(:age)
          }

          result = @adapter.query(collection, &query).all

          users.each do |user|
            record = result.find {|r| r.age == user.age }
            record.wont_be_nil
            record.name.must_be_nil
          end
        end

        it 'returns only the select of requested records' do
          name = user2.name

          query = Proc.new {
            where(name: name).select(:age)
          }

          result = @adapter.query(collection, &query).all

          record = result.first
          record.age.must_equal(user2.age)
          record.name.must_be_nil
        end

        it 'returns only the multiple select of requested records' do
          name = user2.name

          query = Proc.new {
            where(name: name).select(:name, :age)
          }

          result = @adapter.query(collection, &query).all

          record = result.first
          record.name.must_equal(user2.name)
          record.age.must_equal(user2.age)
          record.id.must_be_nil
        end
      end
    end

    describe 'order' do
      describe 'with an empty collection' do
        it 'returns an empty result set' do
          result = @adapter.query(collection) do
            order(:id)
          end.all

          result.must_be_empty
        end
      end

      describe 'with a filled collection' do
        before do
          @user1 = @adapter.create(collection, user1.to_h)
          @user2 = @adapter.create(collection, user2.to_h)
        end

        it 'returns sorted records' do
          query = Proc.new {
            order(:id)
          }

          result = @adapter.query(collection, &query).all
          result.must_equal [@user1, @user2]
        end

        it 'returns sorted records, using multiple columns' do
          query = Proc.new {
            order(:age, :id)
          }

          result = @adapter.query(collection, &query).all
          result.must_equal [@user2, @user1]
        end

        it 'returns sorted records, using multiple invokations' do
          query = Proc.new {
            order(:age).order(:id)
          }

          result = @adapter.query(collection, &query).all
          result.must_equal [@user2, @user1]
        end
      end
    end

    describe 'asc' do
      describe 'with an empty collection' do
        it 'returns an empty result set' do
          result = @adapter.query(collection) do
            asc(:id)
          end.all

          result.must_be_empty
        end
      end

      describe 'with a filled collection' do
        before do
          @user1 = @adapter.create(collection, user1.to_h)
          @user2 = @adapter.create(collection, user2.to_h)
        end

        it 'returns sorted records' do
          query = Proc.new {
            asc(:id)
          }

          result = @adapter.query(collection, &query).all
          result.must_equal [@user1, @user2]
        end
      end
    end

    describe 'desc' do
      describe 'with an empty collection' do
        it 'returns an empty result set' do
          result = @adapter.query(collection) do
            desc(:id)
          end.all

          result.must_be_empty
        end
      end

      describe 'with a filled collection' do
        before do
          @user1 = @adapter.create(collection, user1.to_h)
          @user2 = @adapter.create(collection, user2.to_h)
        end

        it 'returns reverse sorted records' do
          query = Proc.new {
            desc(:id)
          }

          result = @adapter.query(collection, &query).all
          result.must_equal [@user2, @user1]
        end

        it 'returns sorted records, using multiple columns' do
          query = Proc.new {
            desc(:age, :id)
          }

          result = @adapter.query(collection, &query).all
          result.must_equal [@user1, @user2]
        end

        it 'returns sorted records, using multiple invokations' do
          query = Proc.new {
            desc(:age).desc(:id)
          }

          result = @adapter.query(collection, &query).all
          result.must_equal [@user1, @user2]
        end
      end
    end

    describe 'limit' do
      describe 'with an empty collection' do
        it 'returns an empty result set' do
          result = @adapter.query(collection) do
            limit(1)
          end.all

          result.must_be_empty
        end
      end

      describe 'with a filled collection' do
        before do
          @user1 = @adapter.create(collection, user1.to_h)
          @user2 = @adapter.create(collection, user2.to_h)
          @user3 = @adapter.create(collection, TestUser.new(name: user2.name).to_h)
        end

        it 'returns only the number of requested records' do
          name = @user2.name

          query = Proc.new {
            where(name: name).limit(1)
          }

          result = @adapter.query(collection, &query).all
          result.must_equal [@user2]
        end
      end
    end

    describe 'offset' do
      describe 'with an empty collection' do
        it 'returns an empty result set' do
          result = @adapter.query(collection) do
            limit(1).offset(1)
          end.all

          result.must_be_empty
        end
      end

      describe 'with a filled collection' do
        before do
          @user1 = @adapter.create(collection, user1.to_h)
          @user2 = @adapter.create(collection, user2.to_h)
          @user3 = @adapter.create(collection, user3.to_h)
          @user4 = @adapter.create(collection, user4.to_h)
        end

        let(:user3) { TestUser.new(name: user2.name, age: 31) }
        let(:user4) { TestUser.new(name: user2.name, age: 32) }

        it 'returns only the number of requested records' do
          name = @user2.name

          query = Proc.new {
            where(name: name).limit(2).offset(1)
          }

          result = @adapter.query(collection, &query).all
          result.must_equal [@user3, @user4]
        end
      end
    end

    describe 'exist?' do
      describe 'with an empty collection' do
        it 'returns false' do
          result = @adapter.query(collection) do
            where(id: 23)
          end.exist?

          result.must_equal false
        end
      end

      describe 'with a filled collection' do
        before do
          @user1 = @adapter.create(collection, user1.to_h)
          @user2 = @adapter.create(collection, user2.to_h)
        end

        it 'returns true when there are matched records' do
          id = @user1.id

          query = Proc.new {
            where(id: id)
          }

          result = @adapter.query(collection, &query).exist?
          result.must_equal true
        end

        it 'returns false when there are matched records' do
          query = Proc.new {
            where(id: 'unknown')
          }

          result = @adapter.query(collection, &query).exist?
          result.must_equal false
        end
      end
    end

    describe 'count' do
      describe 'with an empty collection' do
        it 'returns 0' do
          result = @adapter.query(collection) do
            all
          end.count

          result.must_equal 0
        end
      end

      describe 'with a filled collection' do
        before do
          @adapter.create(collection, user1.to_h)
          @adapter.create(collection, user2.to_h)
        end

        it 'returns the count of all the records' do
          query = Proc.new {
            all
          }

          result = @adapter.query(collection, &query).count
          result.must_equal 2
        end

        it 'returns the count from an empty query block' do
          query = Proc.new {
          }

          result = @adapter.query(collection, &query).count
          result.must_equal 2
        end

        it 'returns only the count of requested records' do
          name = user2.name

          query = Proc.new {
            where(name: name)
          }

          result = @adapter.query(collection, &query).count
          result.must_equal 1
        end
      end
    end

    describe 'sum' do
      describe 'with an empty collection' do
        it 'returns nil' do
          result = @adapter.query(collection) do
            all
          end.sum(:age)

          result.must_be_nil
        end
      end

      describe 'with a filled collection' do
        before do
          @adapter.create(collection, user1.to_h)
          @adapter.create(collection, user2.to_h)
          @adapter.create(collection, TestUser.new(name: 'S').to_h)
        end

        it 'returns the sum of all the records' do
          query = Proc.new {
            all
          }

          result = @adapter.query(collection, &query).sum(:age)
          result.must_equal 63
        end

        it 'returns the sum from an empty query block' do
          query = Proc.new {
          }

          result = @adapter.query(collection, &query).sum(:age)
          result.must_equal 63
        end

        it 'returns only the sum of requested records' do
          name = user2.name

          query = Proc.new {
            where(name: name)
          }

          result = @adapter.query(collection, &query).sum(:age)
          result.must_equal 31
        end
      end
    end

    describe 'average' do
      describe 'with an empty collection' do
        it 'returns nil' do
          result = @adapter.query(collection) do
            all
          end.average(:age)

          result.must_be_nil
        end
      end

      describe 'with a filled collection' do
        before do
          @adapter.create(collection, user1.to_h)
          @adapter.create(collection, user2.to_h)
          @adapter.create(collection, TestUser.new(name: 'S').to_h)
        end

        it 'returns the average of all the records' do
          query = Proc.new {
            all
          }

          result = @adapter.query(collection, &query).average(:age)
          result.must_equal 31.5
        end

        it 'returns the average from an empty query block' do
          query = Proc.new {
          }

          result = @adapter.query(collection, &query).average(:age)
          result.must_equal 31.5
        end

        it 'returns only the average of requested records' do
          name = user2.name

          query = Proc.new {
            where(name: name)
          }

          result = @adapter.query(collection, &query).average(:age)
          result.must_equal 31
        end
      end
    end

    describe 'avg' do
      describe 'with an empty collection' do
        it 'returns nil' do
          result = @adapter.query(collection) do
            all
          end.avg(:age)

          result.must_be_nil
        end
      end

      describe 'with a filled collection' do
        before do
          @adapter.create(collection, user1.to_h)
          @adapter.create(collection, user2.to_h)
          @adapter.create(collection, TestUser.new(name: 'S').to_h)
        end

        it 'returns the average of all the records' do
          query = Proc.new {
            all
          }

          result = @adapter.query(collection, &query).avg(:age)
          result.must_equal 31.5
        end

        it 'returns the average from an empty query block' do
          query = Proc.new {
          }

          result = @adapter.query(collection, &query).avg(:age)
          result.must_equal 31.5
        end

        it 'returns only the average of requested records' do
          name = user2.name

          query = Proc.new {
            where(name: name)
          }

          result = @adapter.query(collection, &query).avg(:age)
          result.must_equal 31
        end
      end
    end

    describe 'max' do
      describe 'with an empty collection' do
        it 'returns nil' do
          result = @adapter.query(collection) do
            all
          end.max(:age)

          result.must_be_nil
        end
      end

      describe 'with a filled collection' do
        before do
          @adapter.create(collection, user1.to_h)
          @adapter.create(collection, user2.to_h)
          @adapter.create(collection, TestUser.new(name: 'S').to_h)
        end

        it 'returns the maximum of all the records' do
          query = Proc.new {
            all
          }

          result = @adapter.query(collection, &query).max(:age)
          result.must_equal 32
        end

        it 'returns the maximum from an empty query block' do
          query = Proc.new {
          }

          result = @adapter.query(collection, &query).max(:age)
          result.must_equal 32
        end

        it 'returns only the maximum of requested records' do
          name = user2.name

          query = Proc.new {
            where(name: name)
          }

          result = @adapter.query(collection, &query).max(:age)
          result.must_equal 31
        end
      end
    end

    describe 'min' do
      describe 'with an empty collection' do
        it 'returns nil' do
          result = @adapter.query(collection) do
            all
          end.min(:age)

          result.must_be_nil
        end
      end

      describe 'with a filled collection' do
        before do
          @adapter.create(collection, user1.to_h)
          @adapter.create(collection, user2.to_h)
          @adapter.create(collection, TestUser.new(name: 'S').to_h)
        end

        it 'returns the minimum of all the records' do
          query = Proc.new {
            all
          }

          result = @adapter.query(collection, &query).min(:age)
          result.must_equal 31
        end

        it 'returns the minimum from an empty query block' do
          query = Proc.new {
          }

          result = @adapter.query(collection, &query).min(:age)
          result.must_equal 31
        end

        it 'returns only the minimum of requested records' do
          name = user1.name

          query = Proc.new {
            where(name: name)
          }

          result = @adapter.query(collection, &query).min(:age)
          result.must_equal 32
        end
      end
    end

    describe 'interval' do
      describe 'with an empty collection' do
        it 'returns nil' do
          result = @adapter.query(collection) do
            all
          end.interval(:age)

          result.must_be_nil
        end
      end

      describe 'with a filled collection' do
        before do
          @adapter.create(collection, user1.to_h)
          @adapter.create(collection, user2.to_h)
          @adapter.create(collection, TestUser.new(name: 'S').to_h)
        end

        it 'returns the interval of all the records' do
          query = Proc.new {
            all
          }

          result = @adapter.query(collection, &query).interval(:age)
          result.must_equal 1
        end

        it 'returns the interval from an empty query block' do
          query = Proc.new {
          }

          result = @adapter.query(collection, &query).interval(:age)
          result.must_equal 1
        end

        it 'returns only the interval of requested records' do
          name = user1.name

          query = Proc.new {
            where(name: name)
          }

          result = @adapter.query(collection, &query).interval(:age)
          result.must_equal 0
        end
      end
    end

    describe 'range' do
      describe 'with an empty collection' do
        it 'returns nil' do
          result = @adapter.query(collection) do
            all
          end.range(:age)

          result.must_equal nil..nil
        end
      end

      describe 'with a filled collection' do
        before do
          @adapter.create(collection, user1.to_h)
          @adapter.create(collection, user2.to_h)
          @adapter.create(collection, TestUser.new(name: 'S').to_h)
        end

        it 'returns the range of all the records' do
          query = Proc.new {
            all
          }

          result = @adapter.query(collection, &query).range(:age)
          result.must_equal 31..32
        end

        it 'returns the range from an empty query block' do
          query = Proc.new {
          }

          result = @adapter.query(collection, &query).range(:age)
          result.must_equal 31..32
        end

        it 'returns only the range of requested records' do
          name = user2.name

          query = Proc.new {
            where(name: name)
          }

          result = @adapter.query(collection, &query).range(:age)
          result.must_equal 31..31
        end
      end
    end

    describe 'execute' do
      before do
        @adapter.create(collection, user1.to_h)
        @adapter.create(collection, user2.to_h)
      end

      it 'runs the command and returns nil' do
        raw = "UPDATE users SET name='CP'"

        result = @adapter.execute(raw)
        result.must_be_nil

        records = @adapter.all(:users)
        records.all? {|r| r.name == 'CP' }.must_equal true
      end

      it 'raises an exception when invalid sql is provided' do
        raw = "UPDATE users SET foo=22"

        -> { @adapter.execute(raw) }.must_raise Hanami::Model::InvalidCommandError
      end
    end

    describe 'fetch' do
      before do
        UserRepository.adapter = @adapter
        @user1 = @adapter.create(collection, user1.to_h)
      end

      after do
        UserRepository.adapter = nil
      end

      it 'returns the an array from the raw sql' do
        raw = "SELECT * FROM users"

        result = @adapter.fetch(raw)
        result.count.must_equal UserRepository.new.all.count

        user = result.first
        user[:id].must_equal         @user1.id
        user[:name].must_equal       @user1.name
        user[:age].must_equal        @user1.age
        user[:created_at].must_be_nil
        user[:updated_at].must_be_nil
      end

      it 'yields the given block' do
        raw = "SELECT * FROM users"

        # In theory `execute` yields result set in a block
        # https://github.com/jeremyevans/sequel/blob/54fa82326d3319d9aca4409c07f79edc09da3837/lib/sequel/adapters/sqlite.rb#L126-L129
        #
        # Would be interesting in future to wrap these results into Hanami result_sets, independent from
        # Sequel adapter
        #
        records = []

        @adapter.fetch raw do |result_set|
          records << result_set
        end

        records.count.must_equal UserRepository.new.all.count
      end

      it 'raises an exception when an invalid sql is provided' do
        raw = "SELECT foo FROM users"
        -> { @adapter.fetch(raw) }.must_raise Hanami::Model::InvalidQueryError
      end
    end

    describe 'group' do
      describe 'with an empty collection' do
        it 'returns an empty result' do
          result = @adapter.query(collection) do
            group(:name)
          end.all

          result.must_be_empty
        end
      end

      describe 'with a filled collection' do
        before do
          @adapter.create(collection, user1.to_h)
          @adapter.create(collection, user2.to_h)
          @adapter.create(collection, user3.to_h)
          @adapter.create(collection, user4.to_h)
          @adapter.create(collection, user5.to_h)
          @adapter.create(collection, user6.to_h)
          @adapter.create(collection, user7.to_h)
        end

        let(:user1) { TestUser.new(name: 'L', age: 32) }
        let(:user2) { TestUser.new(name: 'L', age: 10) }
        let(:user3) { TestUser.new(name: 'L', age: 11) }
        let(:user4) { TestUser.new(name: 'A', age: 12) }
        let(:user5) { TestUser.new(name: 'A', age: 12) }
        let(:user6) { TestUser.new(name: 'T', age: 11) }
        let(:user7) { TestUser.new(name: 'O', age: 10) }

        it 'returns grouped records with one column' do
          query = Proc.new {
            group(:name)
          }

          result = @adapter.query(collection, &query).all
          result.size.must_equal 4
        end

        it 'returns grouped records with 2 columns' do
          query = Proc.new {
            group(:name, :age)
          }

          result = @adapter.query(collection, &query).all
          result.size.must_equal 6
        end
      end
    end

    describe '#disconnect' do
      before do
        @adapter.disconnect
      end

      it 'raises error' do
        exception = -> { @adapter.create(collection, user1) }.must_raise Hanami::Model::Adapters::DisconnectedAdapterError
        exception.message.must_match "You have tried to perform an operation on a disconnected adapter"
      end
    end

    describe '#adapter_name' do
      it "equals to 'sql'" do
        @adapter.adapter_name.must_equal 'sql'
      end
    end
  end
end
