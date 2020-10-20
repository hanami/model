# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Associations (has_one)" do
  extend PlatformHelpers

  let(:users) { UserRepository.new }
  let(:avatars) { AvatarRepository.new }

  it "returns nil if the association wasn't preloaded" do
    user       = users.create(name: "John Doe")
    found      = users.find(user.id)

    expect(found.avatar).to be_nil
  end

  it "preloads the associated record" do
    user       = users.create(name: "Baruch Spinoza")
    avatar     = avatars.create(user_id: user.id, url: "http://www.notarealurl.com/avatar.png")
    found      = users.find_with_avatar(user.id)
    expect(found).to eq(user)
    expect(found.avatar).to eq(avatar)
  end

  it "returns an Avatar" do
    user       = users.create(name: "Simone de Beauvoir")
    avatar     = avatars.create(user_id: user.id, url: "http://www.notarealurl.com/simone.png")
    found      = users.avatar_for(user)

    expect(found).to eq(avatar)
  end

  it "returns nil if the association was preloaded but no associated object is set" do
    user       = users.create(name: "Henry Jenkins")
    found      = users.find_with_avatar(user.id)

    expect(found).to eq(user)
    expect(found.avatar).to be_nil
  end

  context "#add" do
    it "adds an an Avatar to an existing User" do
      user = users.create(name: "Jean Paul-Sartre")
      avatar = users.add_avatar(user, url: "http://www.notarealurl.com/sartre.png")
      found = users.find_with_avatar(user.id)

      expect(found).to eq(user)
      expect(found.avatar.id).to eq(avatar.id)
      expect(found.avatar.url).to eq("http://www.notarealurl.com/sartre.png")
    end

    it "adds an an Avatar to an existing User when serializable data is received" do
      user = users.create(name: "Jean Paul-Sartre")
      avatar = users.add_avatar(user, BaseParams.new(url: "http://www.notarealurl.com/sartre.png"))
      found = users.find_with_avatar(user.id)

      expect(found).to eq(user)
      expect(found.avatar.id).to eq(avatar.id)
      expect(found.avatar.url).to eq("http://www.notarealurl.com/sartre.png")
    end
  end

  context "#update" do
    it "updates the avatar" do
      user = users.create_with_avatar(name: "Bakunin", avatar: {url: "bakunin.jpg"})
      users.update_avatar(user, url: url = "http://history.com/bakunin.png")

      found = users.find_with_avatar(user.id)

      expect(found).to eq(user)
      expect(found.avatar).to eq(user.avatar)
      expect(found.avatar.url).to eq(url)
    end

    it "updates the avatar when serializable data is received" do
      user = users.create_with_avatar(name: "Bakunin", avatar: {url: "bakunin.jpg"})
      users.update_avatar(user, BaseParams.new(url: url = "http://history.com/bakunin.png"))

      found = users.find_with_avatar(user.id)

      expect(found).to eq(user)
      expect(found.avatar).to eq(user.avatar)
      expect(found.avatar.url).to eq(url)
    end
  end

  context "#create" do
    it "creates a User and an Avatar" do
      user = users.create_with_avatar(name: "Lao Tse", avatar: {url: "http://lao-tse.io/me.jpg"})
      found = users.find_with_avatar(user.id)

      expect(found.name).to eq(user.name)
      expect(found.avatar).to eq(user.avatar)
      expect(found.avatar.url).to eq("http://lao-tse.io/me.jpg")
    end

    it "creates a User and an Avatar when serializable data is received" do
      user = users.create_with_avatar(name: "Lao Tse", avatar: BaseParams.new(url: "http://lao-tse.io/me.jpg"))
      found = users.find_with_avatar(user.id)

      expect(found.name).to eq(user.name)
      expect(found.avatar).to eq(user.avatar)
      expect(found.avatar.url).to eq("http://lao-tse.io/me.jpg")
    end
  end

  context "#delete" do
    it "removes the Avatar" do
      user = users.create_with_avatar(name: "Bob Ross", avatar: {url: "http://bobross/happy_little_avatar.jpg"})
      other = users.create_with_avatar(name: "Candido Portinari", avatar: {url: "some_mugshot.jpg"})
      users.remove_avatar(user)
      found = users.find_with_avatar(user.id)
      other_found = users.find_with_avatar(other.id)

      expect(found.avatar).to be_nil
      expect(other_found.avatar).to be_an Avatar
    end
  end

  context "#replace" do
    it "replaces the associated object" do
      user = users.create_with_avatar(name: "Frank Herbert", avatar: {url: "http://not-real.com/avatar.jpg"})
      users.replace_avatar(user, url: "http://totally-correct.com/avatar.jpg")
      found = users.find_with_avatar(user.id)

      expect(found.avatar).to_not eq(user.avatar)

      expect(avatars.by_user(user.id).size).to eq(1)
    end

    it "replaces the associated object when serializable data is received" do
      user = users.create_with_avatar(name: "Frank Herbert", avatar: {url: "http://not-real.com/avatar.jpg"})
      users.replace_avatar(user, BaseParams.new(url: "http://totally-correct.com/avatar.jpg"))
      found = users.find_with_avatar(user.id)

      expect(found.avatar).to_not eq(user.avatar)

      expect(avatars.by_user(user.id).size).to eq(1)
    end
  end

  context "raises a Hanami::Model::Error wrapped exception on" do
    it "#create" do
      expect do
        users.create_with_avatar(name: "Noam Chomsky")
      end.to raise_error Hanami::Model::Error
    end

    it "#add" do
      user = users.create_with_avatar(name: "Stephen Fry", avatar: {url: "fry_mugshot.png"})
      expect { users.add_avatar(user, url: "new_mugshot.png") }.to raise_error Hanami::Model::UniqueConstraintViolationError
    end

    # by default it seems that MySQL allows you to update a NOT NULL column to a NULL value
    unless_platform(db: :mysql) do
      it "#update" do
        user = users.create_with_avatar(name: "Dan North", avatar: {url: "bdd_creator.png"})

        expect do
          users.update_avatar(user, url: nil)
        end.to raise_error Hanami::Model::NotNullConstraintViolationError
      end
    end

    it "#replace" do
      user = users.create_with_avatar(name: "Eric Evans", avatar: {url: "ddd_man.png"})
      expect { users.replace_avatar(user, url: nil) }.to raise_error Hanami::Model::NotNullConstraintViolationError
    end
  end
end
