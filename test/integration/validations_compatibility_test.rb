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
end
