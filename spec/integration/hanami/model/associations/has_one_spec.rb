require 'spec_helper'

RSpec.describe 'Associations (has_one)' do
  let(:repository) { UserRepository.new }

  it "returns nil if the association wasn't preloaded" do
    user       = repository.create(name: 'John Doe')
    found      = repository.find(user.id)

    expect(found.avatar).to be_nil
  end

  it 'preloads the associated record' do
    user       = repository.create(name: 'Baruch Spinoza')
    avatar     = AvatarRepository.new.create(user_id: user.id, url: 'http://www.notarealurl.com/avatar.png')
    found      = repository.find_with_avatar(user.id)
    expect(found).to eq(user)
    expect(found.avatar).to eq(avatar)
  end

  it 'returns an Avatar' do
    user       = repository.create(name: 'Simone de Beauvoir')
    avatar     = AvatarRepository.new.create(user_id: user.id, url: 'http://www.notarealurl.com/simone.png')
    found      = repository.avatar_for(user)

    expect(found).to eq(avatar)
  end

  it 'adds an an Avatar to an existing User' do
    user       = repository.create(name: 'Jean Paul-Sartre')
    avatar = repository.add_avatar(user, url: 'http://www.notarealurl.com/sartre.png')
    found = repository.find_with_avatar(user.id)

    expect(found).to eq(user)
    expect(found.avatar.id).to eq(avatar.id)
    expect(found.avatar.url).to eq('http://www.notarealurl.com/sartre.png')
  end

  it 'creates a User and an Avatar' do
    user = repository.create_with_avatar(name: 'Lao Tse', avatar: { url: 'http://lao-tse.io/me.jpg' })
    found = repository.find_with_avatar(user.id)

    expect(found.name).to eq(user.name)
    expect(found.avatar).to eq(user.avatar)
    expect(found.avatar.url).to eq('http://lao-tse.io/me.jpg')
  end
end