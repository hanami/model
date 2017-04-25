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
    author = AuthorRepository.new.create(name: 'Michel Foucault')
    book   = repository.create(author_id: author.id, title: 'Surveiller et punir')
    found = repository.find_with_author(book.id)
    found.must_equal book
    found.author.must_equal author
  end

  it 'returns an author' do
    repository = BookRepository.new
    author = AuthorRepository.new.create(name: 'Maurice Leblanc')
    book   = repository.create(author_id: author.id, title: "L'Aguille Creuse")
    found = repository.author_for(book)

    found.must_equal author
  end
end
