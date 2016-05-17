Hanami::Model.migration do
  up do
    create_table :books do
      primary_key :id
      column :title, String, null: false
    end
  end

  down do
    drop_table :title
  end
end
