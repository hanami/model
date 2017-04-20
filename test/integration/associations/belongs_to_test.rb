require 'test_helper'

describe 'Associations (belongs_To)' do
  it "returns nil if association wasn't preloaded" do
    repository = BookRepository.new
    book       = repository.create(name: 'L')
    found      = repository.find(book.id)

    found.author.must_equal nil
  end

  it 'preloads the associated record' do
    repository = BookRepository.new

    author = AuthorRepository.new.create(name: 'Umberto Eco')
    book   = repository.create(author_id: author.id, title: 'Foucault Pendulum')

    found = repository.find_with_author(book.id)

    found.must_equal book
    found.author.must_equal author
  end

  it 'returns an author entity' do
    skip('Still implementing')
    repository = BookRepository.new
    book       = repository.create_with_author(title: "L'Aiguille creuse", author: { name: 'Maurice Leblanc' })

    book.must_be_instance_of(Book)
    book.title.must_equal "L'Aiguille creuse"
    book.author.must_be_instance_of(Author)
    book.author.title.must_equal('Maurice Leblanc')
  end
end
