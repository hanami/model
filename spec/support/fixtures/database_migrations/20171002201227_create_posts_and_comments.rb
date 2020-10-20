# frozen_string_literal: true

Hanami::Model.migration do
  change do
    drop_table?   :posts
    create_table? :posts do
      primary_key :id
      column :title, String
      foreign_key :user_id, :users, on_delete: :cascade, null: false
    end
    drop_table? :comments
    create_table? :comments do
      primary_key :id

      foreign_key :user_id, :users, on_delete: :cascade, null: false
      foreign_key :post_id, :posts, on_delete: :cascade, null: false
    end
  end
end
