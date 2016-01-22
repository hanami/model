require 'test_helper'
require 'hanami/validations'

describe 'Hanami::Validations compatibility' do
  before do
    class Product
      include Hanami::Entity
      include Hanami::Validations

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
