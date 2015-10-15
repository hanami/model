require 'test_helper'

describe Lotus::Entity do
  before do
    class Car
      include Lotus::Entity
    end

    class Book
      include Lotus::Entity
      include Lotus::Entity::DirtyTracking
      attributes :title, :author, :published, :tags
    end

    class NonFictionBook < Book
      attributes :price
    end

    class CoolNonFictionBook < NonFictionBook
      attributes :coolness
    end

    class Camera
      include Lotus::Entity
      attr_accessor :analog
    end
  end

  after do
    [:Car, :Book, :NonFictionBook, :CoolNonFictionBook, :Camera].each do |const|
      Object.send(:remove_const, const)
    end
  end

  describe '.attributes' do
    it 'defines attributes' do
      Car.attributes :model
      Car.attributes.must_equal Set.new([:id, :model])
    end

    describe 'params is array' do
      it 'defines attributes' do
        Car.attributes [:model]
        Car.attributes.must_equal Set.new([:id, :model])
      end
    end
  end

  describe '#initialize' do
    describe 'with defined attributes' do
      it 'accepts given attributes' do
        book = Book.new(title: "A Lover's Discourse: Fragments", author: 'Roland Barthes', published: false)

        book.instance_variable_get(:@title).must_equal  "A Lover's Discourse: Fragments"
        book.instance_variable_get(:@author).must_equal 'Roland Barthes'
        book.instance_variable_get(:@published).must_equal false
      end

      it 'accepts given attributes as string keys' do
        book = Book.new('title' => "A Lover's Discourse: Fragments", 'author' => 'Roland Barthes', 'published' => false)

        book.instance_variable_get(:@title).must_equal  "A Lover's Discourse: Fragments"
        book.instance_variable_get(:@author).must_equal 'Roland Barthes'
        book.instance_variable_get(:@published).must_equal false
      end

      it 'ignores unknown attributes' do
        book = Book.new(unknown: 'x')
        book.instance_variable_get(:@unknown).must_be_nil
      end

      it 'accepts given attributes for subclass' do
        book = NonFictionBook.new(title: 'Refactoring', author: 'Martin Fowler', published: false, price: 50)

        book.instance_variable_get(:@title).must_equal  'Refactoring'
        book.instance_variable_get(:@author).must_equal 'Martin Fowler'
        book.instance_variable_get(:@published).must_equal false
        book.instance_variable_get(:@price).must_equal 50
      end

      it 'accepts given attributes for subclass of subclass' do
        book = CoolNonFictionBook.new(title: 'Refactoring', author: 'Martin Fowler', published: false, price: 50, coolness: 'awesome')

        book.instance_variable_get(:@title).must_equal  'Refactoring'
        book.instance_variable_get(:@author).must_equal 'Martin Fowler'
        book.instance_variable_get(:@published).must_equal false
        book.instance_variable_get(:@price).must_equal 50
        book.instance_variable_get(:@coolness).must_equal 'awesome'
      end

      it "doesn't interfer with superclass attributes" do
        book = CoolNonFictionBook.new(title: "Good Math", author: "Mark C. Chu-Carroll", published: false, coolness: true)

        book.instance_variable_get(:@title).must_equal  'Good Math'
        book.instance_variable_get(:@author).must_equal 'Mark C. Chu-Carroll'
        book.instance_variable_get(:@published).must_equal false
        book.instance_variable_get(:@coolness).must_equal true
      end
    end

    describe 'with undefined attributes' do
      it 'has default accessor for id' do
        camera = Camera.new
        camera.must_respond_to :id
        camera.must_respond_to :id=
      end

      it 'is able to initialize an entity without given attributes' do
        camera = Camera.new
        camera.analog.must_be_nil
      end

      it 'is able to initialize an entity if it has the right accessors' do
        camera = Camera.new(analog: true)
        camera.analog.must_equal(true)
      end

      it "ignores given attributes that don't correspond to known accessors" do
        camera = Camera.new(digital: true)
        camera.wont_respond_to :digital
        camera.wont_respond_to :digital=
      end
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

  describe '#to_h' do
    before do
      @book = Book.new(id: 100, title: 'Wuthering Heights', author: 'Emily Brontë', published: false)
    end

    it 'returns an attributes hash' do
      @book.to_h.must_equal({id: 100, title: 'Wuthering Heights', author: 'Emily Brontë', published: false, tags: nil})
    end
  end

  describe '#attribute_names' do
    before do
      @book = Book.new(id: 100, title: 'Wuthering Heights', author: 'Emily Brontë', published: false)
    end

    it 'returns an attribute names' do
      @book.attribute_names.must_equal Set.new([:id, :title, :author, :published, :tags])
    end
  end

  describe "#inspect, #to_s" do
    before do
      @book = Book.new(id: 100, author: 'Emily Brontë', published: false)
    end

    it 'returns all assigned attributes' do
      @book.stub(:__id__, 70179622946220) do
        @book.inspect.must_equal "#<Book:0x007fa7eefe0b58 @id=100 @title=nil @author=\"Emily Brontë\" @published=false @tags=nil>"
        @book.to_s.must_equal "#<Book:0x007fa7eefe0b58 @id=100 @title=nil @author=\"Emily Brontë\" @published=false @tags=nil>"
      end
    end
  end

  describe '#update' do
    let(:book) { Book.new(id: nil, title: 'Wuthering Meadow', author: 'J. K. Rowling', published: true ) }
    let(:attributes) { Hash[title: 'Wuthering Heights', author: 'Emily Brontë', published: false] }

    it 'updates the attributes' do
      book.update(attributes)
      book.title.must_equal 'Wuthering Heights'
      book.author.must_equal 'Emily Brontë'
      book.published.must_equal false
    end

    describe 'when update non-existing attribute' do
      let(:attributes) { Hash[rating: '5.0'] }

      it 'raises error' do
        exception = -> { book.update(attributes) }.must_raise(NoMethodError)
        exception.message.must_include "undefined method `rating=' for"
      end
    end
  end

  describe 'dirty tracking' do
    describe "initialization" do
      describe "without identity" do
        describe "without attributes" do
          it "hasn't dirty state" do
            book = Book.new

            book.changed?.must_equal false
            book.changed_attributes.must_equal({})
          end
        end

        describe "with attributes" do
          it "has dirty state" do
            book = Book.new({title: 'Crime and Punishment', author: 'Fyodor Dostoyevsky'})

            book.changed?.must_equal false
            book.changed_attributes.must_equal({})
          end
        end
      end

      describe "with identity" do
        describe "with attributes" do
          it "has't dirty state" do
            book = Book.new(id: 1, title: 'Crime and Punishment', author: 'Fyodor Dostoyevsky')

            book.changed?.must_equal false
            book.changed_attributes.must_equal({})
          end
        end
      end
    end

    describe "attr writer" do
      it "tracks dirty state" do
        book = Book.new
        book.changed?.must_equal false

        book.title  = 'War and Peace'
        book.author = nil
        book.changed?.must_equal true

        book.changed_attributes.must_equal(title: nil)
      end

      it "doesn't track dirty state for unchanged values" do
        book = Book.new(title: "Fight Club", author: "Chuck Palahniuk")
        book.title  = "Choke"
        book.author = "Chuck Palahniuk"

        book.changed?.must_equal true
        book.changed_attributes.must_equal(title: "Fight Club")
      end
    end

    describe "#update" do
      it "tracks dirty state" do
        book = Book.new
        book.changed?.must_equal false

        book.update(title: 'War and Peace')
        book.changed?.must_equal true

        book.changed_attributes.must_equal(title: nil)
      end

      it "doesn't track dirty state for unchanged values" do
        book = Book.new(title: "Fight Club", author: "Chuck Palahniuk")
        book.update(title: "Choke", author: "Chuck Palahniuk")

        book.changed?.must_equal true
        book.changed_attributes.must_equal(title: "Fight Club")
      end
    end

    describe "#changed_attributes" do
      it "prevents data escape" do
        book       = Book.new title: 'Master and Margarita'
        book.title = 'Crime and Punishment'

        book.changed_attributes.must_equal({title: 'Master and Margarita'})
        book.changed_attributes.delete(:title)
        book.changed_attributes.must_equal({title: 'Master and Margarita'})
      end

      it "track changes after inplace modification" do
        book = Book.new(title: "Master and margarita", tags: ["rus", "classic"])
        book.tags << "fantasy"

        book.changed?.must_equal true
        book.changed_attributes.must_equal({tags: ["rus", "classic"]})
      end

      it "show all inplace changes" do
        book = Book.new title: 'Master and Margarita', tags: %w(rus classic), author: 'Dostoyevsky'
        book.tags << "fantasy"

        book.changed?.must_equal true
        book.changed_attributes.must_equal({tags: %w(rus classic)})
        book.author = 'Bulgakov'
        book.changed_attributes.must_equal({tags: %w(rus classic), author: 'Dostoyevsky'})
      end
    end

    describe "inheritance" do
      it "make dirty tracking available to descendants" do
        book = NonFictionBook.new
        book.changed?.must_equal false
      end

      it "doesn't interfer with other classes" do
        camera = Camera.new
        camera.wont_respond_to(:changed?)
      end
    end
  end
end
