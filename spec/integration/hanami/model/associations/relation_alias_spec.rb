# frozen_string_literal: true

RSpec.describe "Alias (:as)  support for associations" do
  let(:users) { UserRepository.new(configuration: configuration) }
  let(:posts) { PostRepository.new(configuration: configuration) }
  let(:comments) { CommentRepository.new(configuration: configuration) }

  it "the attribute is named after the association" do
    user = users.create(name: "Jules Verne")
    post = posts.create(title: "World Traveling made easy", user_id: user.id)

    post_found = posts.find_with_author(post.id)
    expect(post_found.author).to eq(user)

    user_found = users.find_with_threads(user.id)
    expect(user_found.threads).to match_array([post])
  end

  it "it works with nested aggregates" do
    user = users.create(name: "Jules Verne")
    post = posts.create(title: "World Traveling made easy", user_id: user.id)
    commenter = users.create(name: "Thomas Reid")
    comments.create(user_id: commenter.id, post_id: post.id)

    found = posts.feed_for(post.id)
    expect(found.author).to eq(user)
    expect(found.comments[0].user).to eq(commenter)
  end

  context "#assoc support (calling assoc by the alias)" do
    it "for #belongs_to" do
      user = users.create(name: "Jules Verne")
      post = posts.create(title: "World Traveling made easy", user_id: user.id)
      commenter = users.create(name: "Thomas Reid")
      comment = comments.create(user_id: commenter.id, post_id: post.id)

      found_author = posts.author_for(post)
      expect(found_author).to eq(user)

      found_commenter = comments.commenter_for(comment)
      expect(found_commenter).to eq(commenter)
    end

    it "for #has_many" do
      user = users.create(name: "Jules Verne")
      post = posts.create(title: "World Traveling made easy", user_id: user.id)

      found_threads = users.threads_for(user)
      expect(found_threads).to match_array [post]
    end

    it "for #has_many :through" do
      user = users.create(name: "Jules Verne")
      post = posts.create(title: "World Traveling made easy", user_id: user.id)
      commenter = users.create(name: "Thomas Reid")
      comments.create(user_id: commenter.id, post_id: post.id)

      commenters = posts.commenters_for(post)

      expect(commenters).to match_array([commenter])
    end
  end
end
