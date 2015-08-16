require 'test_helper'

describe Lotus::Model::Adapters::MemoryAdapter do
  before do
    TestUser = Struct.new(:id, :name, :age) do
      include Lotus::Entity
    end

    class TestUserRepository
      include Lotus::Repository
    end

    TestDevice = Struct.new(:id) do
      include Lotus::Entity
    end

    class TestDeviceRepository
      include Lotus::Repository
    end

    @mapper = Lotus::Model::Mapper.new do
      collection :users do
        entity TestUser

        attribute :id,   Integer
        attribute :name, String
        attribute :age,  Integer
      end

      collection :devices do
        entity TestDevice

        attribute :id, Integer
      end
    end.load!

    @adapter = Lotus::Model::Adapters::MemoryAdapter.new(@mapper)
  end

  after do
    Object.send(:remove_const, :TestUser)
    Object.send(:remove_const, :TestUserRepository)
    Object.send(:remove_const, :TestDevice)
    Object.send(:remove_const, :TestDeviceRepository)
  end

  let(:collection) { :users }

  describe 'multiple collections' do
    it 'create records' do
      user   = TestUser.new
      device = TestDevice.new

      user   = @adapter.create(:users, user)
      device = @adapter.create(:devices, device)

      @adapter.all(:users).must_equal   [user]
      @adapter.all(:devices).must_equal [device]
    end
  end

  describe '#persist' do
    describe 'when the given entity is not persisted' do
      let(:entity) { TestUser.new }

      it 'stores the record and assigns an id' do
        result = @adapter.persist(collection, entity)

        result.id.wont_be_nil
        @adapter.find(collection, result.id).must_equal result
      end
    end

    describe 'when the given entity is persisted' do
      before do
        @entity = @adapter.create(collection, entity)
      end

      let(:entity) { TestUser.new }

      it 'updates the record and leaves untouched the id' do
        id = @entity.id
        id.wont_be_nil

        @entity.name = 'L'
        @adapter.persist(collection, @entity)

        @entity.id.must_equal(id)
        @adapter.find(collection, @entity.id).name.must_equal @entity.name
      end
    end
  end

  describe '#create' do
    let(:entity) { TestUser.new }

    it 'stores the record and assigns an id' do
      result = @adapter.create(collection, entity)

      result.id.wont_be_nil
      @adapter.find(collection, result.id).must_equal result
    end
  end

  describe '#update' do
    before do
      @entity = @adapter.create(collection, entity)
    end

    let(:entity) { TestUser.new(id: nil, name: 'L') }

    it 'stores the changes and leave the id untouched' do
      id = @entity.id

      entity.name = 'MG'
      @adapter.update(collection, @entity)

      @entity.id.must_equal id
      @adapter.find(collection, @entity.id).name.must_equal @entity.name
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
        @entity = @adapter.create(collection, entity)
      end

      let(:entity) { TestUser.new }

      it 'returns all of them' do
        @adapter.all(collection).must_equal [@entity]
      end
    end
  end

  describe '#find' do
    before do
      @entity = @adapter.create(collection, entity)
      @adapter.instance_variable_get(:@collections).fetch(collection).records.store(nil, nil_entity)
    end

    let(:entity)      { TestUser.new }
    let(:nil_entity)  { {id: 0} }

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
        @entity1 = @adapter.create(collection, entity1)
        @entity2 = @adapter.create(collection, entity2)
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
        @entity1 = @adapter.create(collection, entity1)
        @entity2 = @adapter.create(collection, entity2)
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
      @adapter.create(collection, entity)
    end

    let(:entity) { TestUser.new }

    it 'removes all the records' do
      @adapter.clear(collection)
      @adapter.all(collection).must_be_empty
    end

    it 'resets the id counter' do
      @adapter.clear(collection)

      result = @adapter.create(collection, entity)
      result.id.must_equal 1
    end
  end

  describe '#query' do
    before do
      @adapter.clear(collection)
    end

    let(:user1) { TestUser.new(name: 'L',  age: '32') }
    let(:user2) { TestUser.new(name: 'MG', age: 31) }
    let(:user3) { TestUser.new(name: 'JS', age: 31) }

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
          @user1 = @adapter.create(collection, user1)
          @user2 = @adapter.create(collection, user2)
          @user3 = @adapter.create(collection, user3)
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

        it 'requires all conditions be satisfied' do
          name = @user3.name
          age  = @user3.age

          query = Proc.new {
            where(age: age).where(name: name)
          }

          result = @adapter.query(collection, &query).all
          result.must_equal [@user3]
        end

        it 'accepts an array as condition' do
          names = [@user1.name, @user2.name]

          query = Proc.new {
            where(name: names)
          }

          result = @adapter.query(collection, &query).all
          result.must_equal [@user1, @user2]
        end

        it 'accepts a set as condition' do
          names = Set.new([@user1.name, @user2.name])

          query = Proc.new {
            where(name: names)
          }

          result = @adapter.query(collection, &query).all
          result.must_equal [@user1, @user2]
        end

        it 'accepts a range as condition' do
          ages = @user3.age..@user2.age

          query = Proc.new {
            where(age: ages)
          }

          result = @adapter.query(collection, &query).all
          result.must_equal [@user2, @user3]
        end

        it 'accepts a block as condition' do
          query = Proc.new {
            where { age > 31 }
          }

          result = @adapter.query(collection, &query).all
          result.must_equal [@user1]
        end

        it "raises InvalidQueryError when columns are invalid in expression" do
          exception = -> {
            query = Proc.new { where { a > 32 } }
            @adapter.query(collection, &query).all
          }.must_raise(Lotus::Model::InvalidQueryError)

          exception.message.must_equal "Invalid query"
        end

        it "accepts nested block conditions" do
          query = Proc.new {
            where { age > 31 }.where { name == 'L' }
          }

          result = @adapter.query(collection, &query).all
          result.must_equal [@user1]
        end

        it "takes into account both hash and block conditions" do
          query = Proc.new {
            where(age: 32).where { name == 'L' }
          }

          result = @adapter.query(collection, &query).all
          result.must_equal [@user1]
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
          @user1 = @adapter.create(collection, user1)
          @user2 = @adapter.create(collection, user2)
          @user3 = @adapter.create(collection, user3)
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

        it 'accepts a block as condition' do
          query = Proc.new {
            exclude { age > 31 }
          }

          result = @adapter.query(collection, &query).all
          result.must_equal [@user2, @user3]
        end

        it "raises InvalidQueryError when columns are invalid in expression" do
          exception = -> {
            query = Proc.new { exclude { a > 32 } }
            @adapter.query(collection, &query).all
          }.must_raise(Lotus::Model::InvalidQueryError)

          exception.message.must_equal "Invalid query"
        end

        it "accepts nested block conditions" do
          query = Proc.new {
            exclude { age > 31 }.exclude { name == 'MG' }
          }

          result = @adapter.query(collection, &query).all
          result.must_equal [@user3]
        end

        it "takes into account both hash and block conditions" do
          query = Proc.new {
            exclude(age: 32).exclude { name == 'MG' }
          }

          result = @adapter.query(collection, &query).all
          result.must_equal [@user3]
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
          @user1 = @adapter.create(collection, user1)
          @user2 = @adapter.create(collection, user2)
          @user3 = @adapter.create(collection, user3)
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

        it 'returns selected records only from the "or" condition' do
          name2 = @user2.name

          query = Proc.new {
            where(name: 'unknown').or(name: name2)
          }

          result = @adapter.query(collection, &query).all
          result.must_equal [@user2]
        end

        it 'accepts a block as condition' do
          query = Proc.new {
            where(name: "MG").or { age > 31 }
          }

          result = @adapter.query(collection, &query).all
          result.must_equal [@user2, @user1]
        end

        it "raises InvalidQueryError when columns are invalid in expression" do
          exception = -> {
            query = Proc.new { where(name: "MG").or { a > 31 } }
            @adapter.query(collection, &query).all
          }.must_raise(Lotus::Model::InvalidQueryError)

          exception.message.must_equal "Invalid query"
        end

        it "accepts nested block conditions" do
          query = Proc.new {
            where { name == "L" }.or { name == 'MG' }.or { name == "JS" }
          }

          result = @adapter.query(collection, &query).all
          result.must_equal [@user1, @user2, @user3]
        end

        it "takes into account both hash and block conditions" do
          query = Proc.new {
            where(age: 32).or { name == 'MG' }
          }

          result = @adapter.query(collection, &query).all
          result.must_equal [@user1, @user2]
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
          @user1 = @adapter.create(collection, user1)
          @user2 = @adapter.create(collection, user2)
          @user3 = @adapter.create(collection, user3)

          @users = [@user1, @user2, @user3]
        end

        let(:user1) { TestUser.new(name: 'L', age: 32) }
        let(:user3) { TestUser.new(name: 'S') }

        it 'returns the selected columnts from all the records' do
          query = Proc.new {
            select(:age)
          }

          result = @adapter.query(collection, &query).all

          @users.each do |user|
            record = result.find {|r| r.age == user.age }
            record.wont_be_nil
            record.name.must_be_nil
          end
        end

        it 'returns only the select of requested records' do
          name = @user2.name

          query = Proc.new {
            where(name: name).select(:age)
          }

          result = @adapter.query(collection, &query).all

          record = result.first
          record.age.must_equal(@user2.age)
          record.name.must_be_nil
        end

        it 'returns only the multiple select of requested records' do
          name = @user2.name

          query = Proc.new {
            where(name: name).select(:name, :age)
          }

          result = @adapter.query(collection, &query).all

          record = result.first
          record.name.must_equal(@user2.name)
          record.age.must_equal(@user2.age)
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
          @user1 = @adapter.create(collection, user1)
          @user2 = @adapter.create(collection, user2)
        end

        it 'returns sorted records' do
          query = Proc.new {
            order(:id)
          }

          result = @adapter.query(collection, &query).all
          result.must_equal [@user1, @user2]
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
          @user1 = @adapter.create(collection, user1)
          @user2 = @adapter.create(collection, user2)
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
          @user1 = @adapter.create(collection, user1)
          @user2 = @adapter.create(collection, user2)
        end

        it 'returns reverse sorted records' do
          query = Proc.new {
            desc(:id)
          }

          result = @adapter.query(collection, &query).all
          result.must_equal [@user2, @user1]
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
          @user1 = @adapter.create(collection, user1)
          @user2 = @adapter.create(collection, user2)
          @user3 = @adapter.create(collection, TestUser.new(name: user2.name))
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
          @user1 = @adapter.create(collection, user1)
          @user2 = @adapter.create(collection, user2)
          @user3 = @adapter.create(collection, user3)
          @user4 = @adapter.create(collection, user4)
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
          @user1 = @adapter.create(collection, user1)
          @user2 = @adapter.create(collection, user2)
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
          result.must_equal 31.0
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
          result.must_equal 31.0
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

    describe '#disconnect' do
      before do
        @adapter.disconnect
      end

      it 'raises error' do
        exception = -> { @adapter.create(collection, TestUser.new) }.must_raise Lotus::Model::Adapters::DisconnectedAdapterError
        exception.message.must_match "You have tried to perform an operation on a disconnected adapter"
      end
    end
  end
end
