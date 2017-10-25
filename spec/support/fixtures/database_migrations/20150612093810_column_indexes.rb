Hanami::Model.migration do
  change do
    create_table :column_indexes do
      column :a, Integer
      column :b, Integer, index: false
      column :c, Integer, index: true
      column :d, Integer

      column :lat, Float
      column :lng, Float

      index :d, unique: true
      index %i[b c]
      index %i[lat lng], name: :column_indexes_coords_index
    end
  end
end
