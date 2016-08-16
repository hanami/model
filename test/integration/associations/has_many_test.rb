require 'test_helper'

describe 'Associations (has_many)' do
  it "returns nil if association wasn't preloaded" do
    repository = AuthorRepository.new
    author = repository.create(name: 'L')
    found  = repository.find(author.id)

    found.books.must_be_nil
  end

  it 'preloads associated records' do
    repository = AuthorRepository.new

    author  = repository.create(name: 'Avdi')
    book    = BookRepository.new.create(author_id: author.id, title: 'Confident Ruby')

    found = repository.find_with_books(author.id)

    found.must_equal author
    # found.books.must_equal [book]
    found.books.map(&:to_h).must_equal [book.to_h]
  end
end
