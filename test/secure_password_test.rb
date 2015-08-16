require 'test_helper'

describe Lotus::Entity::SecurePassword do
  before do
    class Person
      include Lotus::Entity
      include Lotus::Entity::SecurePassword
    end
  end

  subject { Person.new }

  it 'adds a `password` attribute' do
    subject.must_respond_to :password
  end

  it 'adds a `password_confirmation` attribute' do
    subject.must_respond_to :password_confirmation
  end

  it 'adds a `password_digest` attribute' do
    subject.must_respond_to :password_digest
  end

  it 'ensures `password` is confirmed' do
    subject.password = 'password'
    subject.password_confirmation = 'passwelp'

    subject.wont_be :valid?
  end

  it 'ensures password is no more than 72 characters' do
    subject.password = subject.password_confirmation = '*' * 73

    subject.wont_be :valid?
  end

  it 'is valid when the password is confirmed' do
    subject.password = subject.password_confirmation = 'password'

    subject.must_be :valid?
  end

  it 'assigning a nil password clears the digest' do
    subject.password_digest = 'password'
    subject.password = nil

    subject.password_digest.must_be :nil?
  end

  it 'assigning an empty password does not modify the digest' do
    subject.password_digest = 'password'
    subject.password = ''

    subject.password_digest.must_equal 'password'
  end

  it 'assigning a non-empty password sets the digest' do
    subject.password = 'password'

    subject.password_digest.wont_equal nil
  end

  describe '#authenticate' do
    it 'returns `self` when the secret is correct' do
      subject.password = 'password'

      subject.authenticate('password').must_equal subject
    end

    it 'returns false when the secret is incorrect' do
      subject.password = 'password'

      subject.authenticate('incorrect').must_equal false
    end
  end
end
