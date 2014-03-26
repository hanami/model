require 'test_helper'

describe Lotus::Entity do
  before do
    class Car
      include Lotus::Entity
    end

    class Book
      include Lotus::Entity
      self.attributes = :title, :author
    end

    class NonFinctionBook < Book
    end
  end

  after do
    [:Car, :Book, :NonFinctionBook].each do |const|
      Object.send(:remove_const, const)
    end
  end

  describe 'attributes' do
    let(:attributes) { [:model] }

    it 'defines attributes' do
      Car.send(:attributes=, attributes)
      Car.send(:attributes).must_equal attributes
    end
  end

  describe 'primary key' do
    after do
      Book.primary_key = :id
      NonFinctionBook.primary_key = :id
    end

    it 'is :id by default' do
      Car.primary_key.must_equal :id
    end

    it 'can be set to a different value' do
      Book.primary_key = :_id
      Book.primary_key.must_equal :_id
    end

    it 'is inherited by subclasses' do
      NonFinctionBook.primary_key.must_equal :id
    end

    it 'can be changed by subclasses without affecting superclass value' do
      NonFinctionBook.primary_key = :__id
      Book.primary_key.must_equal :id
    end
  end

  describe '#initialize' do
    it 'accepts given attributes' do
      book = Book.new(title: "A Lover's Discourse: Fragments", author: 'Roland Barthes')

      book.instance_variable_get(:@title).must_equal  "A Lover's Discourse: Fragments"
      book.instance_variable_get(:@author).must_equal 'Roland Barthes'
    end

    it 'ignores unknown attributes' do
      book = Book.new(unknown: 'x')

      book.instance_variable_get(:@book).must_be_nil
    end

    it 'accepts given attributes for subclass' do
      book = NonFinctionBook.new(title: 'Refactoring', author: 'Martin Fowler')

      book.instance_variable_get(:@title).must_equal  'Refactoring'
      book.instance_variable_get(:@author).must_equal 'Martin Fowler'
    end
  end

  describe 'accessors' do
    it 'exposes getters for attributes' do
      book = Book.new(title: 'High Fidelity')

      book.title.must_equal 'High Fidelity'
    end

    it 'exposes setters for attributes' do
      book = Book.new
      book.title = 'A Man'

      book.instance_variable_get(:@title).must_equal 'A Man'
      book.title.must_equal 'A Man'
    end

    it 'exposes accessor for id' do
      book = Book.new
      book.id.must_be_nil

      book.id = 23
      book.id.must_equal 23
    end
  end

  describe '#==' do
    before do
      @book1 = Book.new
      @book1.id = 23

      @book2 = Book.new
      @book2.id = 23

      @book3 = Book.new
      @car   = Car.new
    end

    it 'returns true if they have the same class and id' do
      @book1.must_equal @book2
    end

    it 'returns false if they have the same class but different id' do
      @book1.wont_equal @book3
    end

    it 'returns false if they have different class' do
      @book1.wont_equal @car
    end
  end
end
