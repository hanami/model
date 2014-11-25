require 'test_helper'

describe Lotus::Model::Adapters::SqlAdapter do
  before do
    TestUser = Struct.new(:id, :country_id, :name, :age) do
      include Lotus::Entity
    end

    TestDevice = Struct.new(:id, :u_id) do
      include Lotus::Entity
    end

    TestOrder = Struct.new(:id, :user_id, :total) do
      include Lotus::Entity
    end

    TestAge = Struct.new(:id, :value, :label) do
      include Lotus::Entity
    end

    TestCountry = Struct.new(:id, :code) do
      include Lotus::Entity
    end

    @mapper = Lotus::Model::Mapper.new do
      collection :users do
        entity TestUser

        attribute :id,         Integer
        attribute :country_id, Integer
        attribute :name,       String
        attribute :age,        Integer
      end

      collection :devices do
        entity TestDevice

        attribute :id,   Integer
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
        entity TestAge

        attribute :id,   Integer, as: :country_id
        attribute :code, String
      end
    end.load!

    @adapter = Lotus::Model::Adapters::SqlAdapter.new(@mapper, SQLITE_CONNECTION_STRING)
    @adapter.clear(collection)
  end

  after do
    Object.send(:remove_const, :TestUser)
    Object.send(:remove_const, :TestDevice)
    Object.send(:remove_const, :TestOrder)
    Object.send(:remove_const, :TestAge)
    Object.send(:remove_const, :TestCountry)
  end

  let(:collection) { :users }

  describe 'multiple collections' do
    before do
      @adapter.clear(:devices)
    end

    it 'create records' do
      user   = TestUser.new
      device = TestDevice.new

      @adapter.create(:users, user)
      @adapter.create(:devices, device)

      @adapter.all(:users).must_equal   [user]
      @adapter.all(:devices).must_equal [device]
    end
  end

  describe '#initialize' do
    it 'raises an error when the given URI refers to a non registered database adapter' do
      -> {
        Lotus::Model::Adapters::SqlAdapter.new(@mapper, 'postgres://host')
      }.must_raise(Lotus::Model::Adapters::DatabaseAdapterNotFound)
    end

    it 'raises an error when the given URI refers to an unknown database adapter' do
      -> {
        Lotus::Model::Adapters::SqlAdapter.new(@mapper, 'unknown://host')
      }.must_raise(Lotus::Model::Adapters::DatabaseAdapterNotFound)
    end

    it 'raises an error when the given URI is malformed' do
      -> {
        Lotus::Model::Adapters::SqlAdapter.new(@mapper, 'unknown_db:host')
      }.must_raise(URI::InvalidURIError)
    end
  end

  describe '#persist' do
    describe 'when the given entity is not persisted' do
      let(:entity) { TestUser.new }

      it 'stores the record and assigns an id' do
        @adapter.persist(collection, entity)

        entity.id.wont_be_nil
        @adapter.find(collection, entity.id).must_equal entity
      end
    end

    describe 'when the given entity is persisted' do
      before do
        @adapter.create(collection, entity)
      end

      let(:entity) { TestUser.new }

      it 'updates the record and leaves untouched the id' do
        id = entity.id
        id.wont_be_nil

        entity.name = 'L'
        @adapter.persist(collection, entity)

        entity.id.must_equal(id)
        @adapter.find(collection, entity.id).name.must_equal entity.name
      end
    end
  end

  describe '#create' do
    let(:entity) { TestUser.new }

    it 'stores the record and assigns an id' do
      @adapter.create(collection, entity)

      entity.id.wont_be_nil
      @adapter.find(collection, entity.id).must_equal entity
    end
  end

  describe '#update' do
    before do
      @adapter.create(collection, entity)
    end

    let(:entity) { TestUser.new(id: nil, name: 'L') }

    it 'stores the changes and leave the id untouched' do
      id = entity.id

      entity.name = 'MG'
      @adapter.update(collection, entity)

      entity.id.must_equal id
      @adapter.find(collection, entity.id).name.must_equal entity.name
    end
  end

  describe '#delete' do
    before do
      @adapter.create(collection, entity)
    end

    let(:entity) { TestUser.new }

    it 'removes the given identity' do
      @adapter.delete(collection, entity)
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
        @adapter.create(collection, entity)
      end

      let(:entity) { TestUser.new }

      it 'returns all of them' do
        @adapter.all(collection).must_equal [entity]
      end
    end
  end

  describe '#find' do
    before do
      @adapter.create(collection, entity)
    end

    let(:entity) { TestUser.new }

    it 'returns the record by id' do
      @adapter.find(collection, entity.id).must_equal entity
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
        @adapter.create(collection, entity1)
        @adapter.create(collection, entity2)
      end

      let(:entity1) { TestUser.new }
      let(:entity2) { TestUser.new }

      it 'returns the first record' do
        @adapter.first(collection).must_equal entity1
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
        @adapter.create(collection, entity1)
        @adapter.create(collection, entity2)
      end

      let(:entity1) { TestUser.new }
      let(:entity2) { TestUser.new }

      it 'returns the last record' do
        @adapter.last(collection).must_equal entity2
      end
    end
  end

  describe '#clear' do
    before do
      @adapter.create(collection, entity)
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
          @adapter.create(collection, user1)
          @adapter.create(collection, user2)
        end

        it 'returns selected records' do
          id = user1.id

          query = Proc.new {
            where(id: id)
          }

          result = @adapter.query(collection, &query).all
          result.must_equal [user1]
        end

        it 'can use multiple where conditions' do
          id   = user1.id
          name = user1.name

          query = Proc.new {
            where(id: id).where(name: name)
          }

          result = @adapter.query(collection, &query).all
          result.must_equal [user1]
        end

        it 'can use multiple where conditions with "and" alias' do
          id   = user1.id
          name = user1.name

          query = Proc.new {
            where(id: id).and(name: name)
          }

          result = @adapter.query(collection, &query).all
          result.must_equal [user1]
        end

        it 'can use lambda to describe where conditions' do
          query = Proc.new {
            where{ age > 31 }
          }

          result = @adapter.query(collection, &query).all
          result.must_equal [user1]
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
          @adapter.create(collection, user1)
          @adapter.create(collection, user2)
          @adapter.create(collection, user3)
        end

        it 'returns selected records' do
          id = user1.id

          query = Proc.new {
            exclude(id: id)
          }

          result = @adapter.query(collection, &query).all
          result.must_equal [user2, user3]
        end

        it 'can use multiple exclude conditions' do
          id   = user1.id
          name = user2.name

          query = Proc.new {
            exclude(id: id).exclude(name: name)
          }

          result = @adapter.query(collection, &query).all
          result.must_equal [user3]
        end

        it 'can use multiple exclude conditions with "not" alias' do
          id   = user1.id
          name = user2.name

          query = Proc.new {
            self.not(id: id).not(name: name)
          }

          result = @adapter.query(collection, &query).all
          result.must_equal [user3]
        end

        it 'can use lambda to describe exclude conditions' do
          query = Proc.new {
            exclude{ age > 31 }
          }

          result = @adapter.query(collection, &query).all
          result.must_equal [user2, user3]
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
          @adapter.create(collection, user1)
          @adapter.create(collection, user2)
        end

        it 'returns selected records' do
          name1 = user1.name
          name2 = user2.name

          query = Proc.new {
            where(name: name1).or(name: name2)
          }

          result = @adapter.query(collection, &query).all
          result.must_equal [user1, user2]
        end

        it 'can use lambda to describe or conditions' do
          name1 = user1.name

          query = Proc.new {
            where(name: name1).or{ age < 32 }
          }

          result = @adapter.query(collection, &query).all
          result.must_equal [user1, user2]
        end

        it 'raises an error if you dont specify condition or block' do
          -> {
            name1 = user1.name

            query = Proc.new {
              where(name: name1).or()
            }
            @adapter.query(collection, &query).all
          }.must_raise(ArgumentError)
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
          @adapter.create(collection, user1)
          @adapter.create(collection, user2)
          @adapter.create(collection, user3)
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
          @adapter.create(collection, user1)
          @adapter.create(collection, user2)
        end

        it 'returns sorted records' do
          query = Proc.new {
            order(:id)
          }

          result = @adapter.query(collection, &query).all
          result.must_equal [user1, user2]
        end

        it 'returns sorted records, using multiple columns' do
          query = Proc.new {
            order(:age, :id)
          }

          result = @adapter.query(collection, &query).all
          result.must_equal [user2, user1]
        end

        it 'returns sorted records, using multiple invokations' do
          query = Proc.new {
            order(:age).order(:id)
          }

          result = @adapter.query(collection, &query).all
          result.must_equal [user2, user1]
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
          @adapter.create(collection, user1)
          @adapter.create(collection, user2)
        end

        it 'returns sorted records' do
          query = Proc.new {
            asc(:id)
          }

          result = @adapter.query(collection, &query).all
          result.must_equal [user1, user2]
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
          @adapter.create(collection, user1)
          @adapter.create(collection, user2)
        end

        it 'returns reverse sorted records' do
          query = Proc.new {
            desc(:id)
          }

          result = @adapter.query(collection, &query).all
          result.must_equal [user2, user1]
        end

        it 'returns sorted records, using multiple columns' do
          query = Proc.new {
            desc(:age, :id)
          }

          result = @adapter.query(collection, &query).all
          result.must_equal [user1, user2]
        end

        it 'returns sorted records, using multiple invokations' do
          query = Proc.new {
            desc(:age).desc(:id)
          }

          result = @adapter.query(collection, &query).all
          result.must_equal [user1, user2]
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
          @adapter.create(collection, user1)
          @adapter.create(collection, user2)
          @adapter.create(collection, TestUser.new(name: user2.name))
        end

        it 'returns only the number of requested records' do
          name = user2.name

          query = Proc.new {
            where(name: name).limit(1)
          }

          result = @adapter.query(collection, &query).all
          result.must_equal [user2]
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
          @adapter.create(collection, user1)
          @adapter.create(collection, user2)
          @adapter.create(collection, user3)
        end

        let(:user3) { TestUser.new(name: user2.name) }

        it 'returns only the number of requested records' do
          name = user2.name

          query = Proc.new {
            where(name: name).limit(1).offset(1)
          }

          result = @adapter.query(collection, &query).all
          result.must_equal [user3]
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
          @adapter.create(collection, user1)
          @adapter.create(collection, user2)
        end

        it 'returns true when there are matched records' do
          id = user1.id

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
          @adapter.create(collection, user1)
          @adapter.create(collection, user2)
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
          @adapter.create(collection, user1)
          @adapter.create(collection, user2)
          @adapter.create(collection, TestUser.new(name: 'S'))
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
          @adapter.create(collection, user1)
          @adapter.create(collection, user2)
          @adapter.create(collection, TestUser.new(name: 'S'))
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
          @adapter.create(collection, user1)
          @adapter.create(collection, user2)
          @adapter.create(collection, TestUser.new(name: 'S'))
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
          @adapter.create(collection, user1)
          @adapter.create(collection, user2)
          @adapter.create(collection, TestUser.new(name: 'S'))
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
          @adapter.create(collection, user1)
          @adapter.create(collection, user2)
          @adapter.create(collection, TestUser.new(name: 'S'))
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
          @adapter.create(collection, user1)
          @adapter.create(collection, user2)
          @adapter.create(collection, TestUser.new(name: 'S'))
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
          @adapter.create(collection, user1)
          @adapter.create(collection, user2)
          @adapter.create(collection, TestUser.new(name: 'S'))
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

    describe 'join' do
      before do
        @adapter.clear(:orders)
      end

      describe 'inner' do
        describe 'with an empty collection' do
          it 'returns an empty result set' do
            result = @adapter.query(:orders) do
              join(:users)
            end.all

            result.must_be_empty
          end
        end

        describe 'with a filled collection' do
          describe 'and default options' do
            before do
              @adapter.create(collection, user1)

              @order1 = TestOrder.new(user_id: user1.id, total: 100)
              @order2 = TestOrder.new(user_id: user1.id, total: 200)
              @order3 = TestOrder.new(user_id: nil,      total: 300)

              @adapter.create(:orders, @order1)
              @adapter.create(:orders, @order2)
              @adapter.create(:orders, @order3)
            end

            it 'returns records' do
              query = Proc.new {
                join(:users)
              }

              result = @adapter.query(:orders, &query).all
              result.must_equal [@order1, @order2]
            end
          end

          describe 'and explicit key' do
            before do
              @country1 = TestCountry.new(code: 'IT')
              @country2 = TestCountry.new(code: 'US')

              @adapter.create(:countries, @country1)
              @adapter.create(:countries, @country2)

              @user = TestUser.new(country_id: @country2.id)
              @adapter.create(collection, @user)
            end

            it 'returns records' do
              query = Proc.new {
                join(:countries, key: :country_id)
              }

              result = @adapter.query(:users, &query).all
              result.must_equal [@user]
            end
          end

          describe 'and explicit foreign key' do
            before do
              @adapter.create(collection, user1)

              @device1 = TestDevice.new(u_id: user1.id)
              @device2 = TestDevice.new(u_id: user1.id)
              @device3 = TestDevice.new(u_id: nil)

              @adapter.create(:devices, @device1)
              @adapter.create(:devices, @device2)
              @adapter.create(:devices, @device3)
            end

            it 'returns records' do
              query = Proc.new {
                join(:users, foreign_key: :u_id)
              }

              result = @adapter.query(:devices, &query).all
              result.must_equal [@device1, @device2]
            end
          end

          describe 'and explicit key and foreign key' do
            before do
              @adapter.clear(collection)

              @adapter.create(collection, user1)
              @adapter.create(collection, user2)
              @adapter.create(collection, user3)

              @age1 = TestAge.new(value: user1.age, label: 'Adulthood')
              @age2 = TestAge.new(value: user3.age, label: 'Childhood')

              @adapter.create(:ages, @age1)
              @adapter.create(:ages, @age2)
            end

            it 'returns records' do
              query = Proc.new {
                join(:ages, key: :value, foreign_key: :age)
              }

              result = @adapter.query(:users, &query).all
              result.must_equal [user1, user3]
            end
          end
        end
      end
    end
  end
end
