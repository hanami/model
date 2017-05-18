Hanami::Model.migration do
  change do
    drop_table?   :books
    create_table? :books do
      primary_key :id
      foreign_key :author_id, :authors, on_delete: :cascade
      column :title,      String
      column :on_sale,    TrueClass, null: false, default: false
      column :created_at, DateTime,  null: false
      column :updated_at, DateTime,  null: false
    end
  end
end
