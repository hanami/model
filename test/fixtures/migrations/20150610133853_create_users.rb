Lotus::Model.migration do
  up do
    create_table :users do
      primary_key :id
      column :name, :string, null: false
    end
  end

  down do
    drop_table :users
  end
end
