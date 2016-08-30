Hanami::Model.migration do
  change do
    drop_table?   :users
    create_table? :users do
      primary_key :id
      column :name, String
      column :comments_count, Integer,   null: false, default: 0
      column :active,         TrueClass, null: false, default: true
      column :created_at,     DateTime,  null: false
      column :updated_at,     DateTime,  null: false
    end
  end
end
