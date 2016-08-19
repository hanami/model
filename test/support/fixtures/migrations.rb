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

    drop_table?   :authors
    create_table? :authors do
      primary_key :id
      column :name,       String
      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end

    drop_table?   :books
    create_table? :books do
      primary_key :id
      foreign_key :author_id, :authors, on_delete: :cascade
      column :title,      String
      column :on_sale,    TrueClass, null: false, default: false
      column :created_at, DateTime,  null: false
      column :updated_at, DateTime,  null: false
    end

    drop_table?   :t_operator
    create_table? :t_operator do
      primary_key :operator_id
      column :s_name, String
    end
  end
end.run
