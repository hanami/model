require 'test_helper'
require 'hanami/model/migrator'

describe 'SQL joins test' do
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


  describe '#query' do
    let(:user1) { TestUser.new(name: 'L',  age: '32') }
    let(:user2) { TestUser.new(name: 'MG', age: 31)   }
    let(:user3) { TestUser.new(name: 'S',  age: 2)    }

    describe 'join' do
      describe 'inner' do
        describe 'with an empty collection' do
          before do
            @adapter.clear(:orders)
            @adapter.clear(:users)
          end

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
              @adapter.clear(:users)
              @adapter.clear(:orders)

              @created_user = @adapter.create(:users, user1.to_h)

              @order1 = TestOrder.new(user_id: @created_user.id, total: 100)
              @order2 = TestOrder.new(user_id: @created_user.id, total: 200)
              @order3 = TestOrder.new(user_id: nil,              total: 300)

              @adapter.create(:orders, @order1.to_h)
              @adapter.create(:orders, @order2.to_h)
              @adapter.create(:orders, @order3.to_h)

              TestUserRepository.adapter = @adapter
              TestOrderRepository.adapter = @adapter
            end

            it 'returns records' do
              created_user = @created_user

              query_where = Proc.new {
                where(user_id: created_user.id)
              }
              query_join = Proc.new {
                join(:users)
              }

              result_query_where = @adapter.query(:orders, &query_where).all
              result_query_join  = @adapter.query(:orders, &query_join).all

              result_query_join.must_equal result_query_where
            end
          end

          describe 'and explicit key' do
            before do
              @adapter.clear(:users)
              @adapter.clear(:countries)

              @country1 = TestCountry.new(code: 'IT')
              @country2 = TestCountry.new(code: 'US')

              country1 = @adapter.create(:countries, @country1.to_h)
              country2 = @adapter.create(:countries, @country2.to_h)

              user = TestUser.new(country_id: country2.id)
              @created_user = @adapter.create(:users, user.to_h)

              TestUserRepository.adapter = @adapter
              TestCountryRepository.adapter = @adapter
            end

            it 'returns records' do
              query = Proc.new {
                join(:countries, key: :country_id)
              }

              result = @adapter.query(:users, &query).all
              result.must_equal [@created_user]
            end
          end

          describe 'and explicit foreign key' do
            before do
              @adapter.clear(:users)
              @adapter.clear(:devices)

              @created_user = @adapter.create(:users, user1.to_h)

              @device1 = TestDevice.new(u_id: @created_user.id)
              @device2 = TestDevice.new(u_id: @created_user.id)
              @device3 = TestDevice.new(u_id: nil)

              @adapter.create(:devices, @device1.to_h)
              @adapter.create(:devices, @device2.to_h)
              @adapter.create(:devices, @device3.to_h)

              TestUserRepository.adapter = @adapter
            end

            it 'returns records' do
              created_user = @created_user

              query_where = Proc.new {
                where(u_id: created_user.id)
              }
              query_join = Proc.new {
                join(:users, foreign_key: :u_id)
              }

              result_query_where = @adapter.query(:devices, &query_where).all
              result_query_join  = @adapter.query(:devices, &query_join).all

              result_query_join.must_equal result_query_where
            end
          end

          describe 'and explicit key and foreign key' do
            before do
              @adapter.clear(:users)
              @adapter.clear(:ages)

              created_user1 = @adapter.create(:users, user1.to_h)
              @adapter.create(:users, user2.to_h)
              created_user3 = @adapter.create(:users, user3.to_h)

              @age1 = TestAge.new(value: created_user1.age, label: 'Adulthood')
              @age2 = TestAge.new(value: created_user3.age, label: 'Childhood')

              @adapter.create(:ages, @age1.to_h)
              @adapter.create(:ages, @age2.to_h)

              TestUserRepository.adapter = @adapter
            end

            it 'returns records' do
              user_first = TestUserRepository.new.first
              user_last = TestUserRepository.new.last

              query_join = Proc.new {
                join(:ages, key: :value, foreign_key: :age)
              }

              result = @adapter.query(:users, &query_join).all
              result.must_equal [user_first, user_last]
            end
          end
        end
      end

      describe 'left join' do
        describe 'with an empty collection' do
          before do
            @adapter.clear(:orders)
            @adapter.clear(:users)
          end

          it 'returns an empty result set' do
            result = @adapter.query(:orders) do
              left_join(:users)
            end.all

            result.must_be_empty
          end
        end

        describe 'with a filled collection' do
          describe 'and default options' do
            before do
              @adapter.clear(:users)
              @adapter.clear(:orders)

              @created_user = @adapter.create(:users, user1.to_h)

              @order1 = TestOrder.new(user_id: @created_user.id, total: 100)
              @order2 = TestOrder.new(user_id: @created_user.id, total: 200)
              @order3 = TestOrder.new(user_id: nil,              total: 300)

              @adapter.create(:orders, @order1.to_h)
              @adapter.create(:orders, @order2.to_h)
              @adapter.create(:orders, @order3.to_h)

              TestUserRepository.adapter = @adapter
              TestOrderRepository.adapter = @adapter
            end

            it 'returns records' do
              created_user = TestUserRepository.new.first

              query_join = Proc.new {
                left_join(:users)
              }

              result_query_join  = @adapter.query(:orders, &query_join).all
              result_query_join.select{ |order| order.user_id == created_user.id }.size.must_equal 2
              result_query_join.select{ |order| order.user_id.nil? }.size.must_equal 1
              result_query_join.size.must_equal 3
            end
          end
        end
      end
    end
  end
end
