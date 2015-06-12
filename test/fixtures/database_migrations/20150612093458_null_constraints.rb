Lotus::Model.migration do
  change do
    create_table :null_constraints do
      column :a, Integer
      column :b, Integer, null: false
      column :c, Integer, null: true
    end
  end
end
