Hanami::Model.migration do
  change do
    drop_table?   :wharehouses
    create_table? :wharehouses do
      primary_key :id
      column :name,       String
      column :code,       String
      column :created_at, DateTime,  null: false
      column :updated_at, DateTime,  null: false
    end
  end
end
