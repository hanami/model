require 'test_helper'
require 'lotus/validations'

describe 'Lotus::Validations compatibility' do
  before do
    class Product
      include Lotus::Entity
      include Lotus::Validations

      attribute :price, type: Integer
      attributes :price
    end
  end

  after do
    Object.__send__(:remove_const, :Product)
  end

  it "doesn't override already set accessor" do
    product = Product.new(price: '100')
    product.price.must_equal 100
  end

  describe 'inverting order Lotus::Entity::DirtyTracking and Lotus::Validations' do
    describe 'Lotus::Entity::DirtyTracking above Lotus::Validations' do
      before do
        class Product
          include Lotus::Entity
          include Lotus::Entity::DirtyTracking
          include Lotus::Validations

          attribute :price, type: Integer
        end
      end

      describe '#changed?' do
        let (:product) { Product.new(price: '100') }
        it 'do not change' do
          product.changed?.must_equal false
        end

        it 'do change' do
          product.price = '200'
          product.changed?.must_equal true
        end
      end
    end

    describe 'Lotus::Validations above Lotus::Entity::DirtyTracking' do
      before do
        class Product
          include Lotus::Entity
          include Lotus::Validations
          include Lotus::Entity::DirtyTracking

          attribute :price, type: Integer
        end
      end

      describe '#changed?' do
        let (:product) { Product.new(price: '100') }
        it 'do not change' do
          product.changed?.must_equal false
        end

        it 'do change' do
          product.price = '200'
          product.changed?.must_equal true
        end
      end
    end
  end
end
