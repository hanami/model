Lotus::Model.migration do
  change do
    create_table :column_indexes do
      column :a, Integer
      column :b, Integer, index: false
      column :c, Integer, index: true
    end
  end
end
