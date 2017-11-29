# frozen_string_literal: true

Hanami::Model.migration do
  change do
    drop_table?   :avatars
    create_table? :avatars do
      primary_key :id
      foreign_key :user_id, :users, on_delete: :cascade, null: false, unique: true

      column :url, String, null: false
      column :created_at, DateTime
    end
  end
end
