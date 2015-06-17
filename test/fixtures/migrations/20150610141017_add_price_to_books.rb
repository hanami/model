Lotus::Model.migration do
  up do
    add_column :books, :price, 'integer', default: 100
  end

  down do
    drop_column :books, :price
  end
end
