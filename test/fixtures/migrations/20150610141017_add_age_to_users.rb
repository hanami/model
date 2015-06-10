Lotus::Model.migration do
  up do
    add_column :users, :age, 'integer', default: 18
  end

  down do
    drop_column :users, :age
  end
end
