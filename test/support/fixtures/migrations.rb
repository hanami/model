Hanami::Model.migration do
  change do
    drop_table?   :users
    create_table? :users do
      primary_key :id
      column :name, String
      column :comments_count, Integer,  null: false, default: 0
      column :created_at,     DateTime, null: false
      column :updated_at,     DateTime, null: false
    end

    drop_table?   :comments
    create_table? :comments do
      primary_key :id
      foreign_key :user_id, :users, on_delete: :cascade, null: false
      column :text, String
      column :spam, TrueClass, null: false, default: false
    end

    drop_table?   :t_operator
    create_table? :t_operator do
      primary_key :operator_id
      column :s_name, String
    end
  end
end.run
