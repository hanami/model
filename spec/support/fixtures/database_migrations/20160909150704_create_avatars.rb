Hanami::Model.migration do
  change do
    drop_table?   :avatars
    create_table? :avatars do
      primary_key :id
      foreign_key :user_id, :users, on_delete: :cascade, null: false

      column :url, String
      column :created_at, DateTime
    end
  end
end
