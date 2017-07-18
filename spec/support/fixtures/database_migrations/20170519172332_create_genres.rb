Hanami::Model.migration do
  change do
    drop_table?   :genres
    create_table? :genres do
      primary_key :id
      column :name, String
    end
    drop_table? :books_genres
    create_table? :books_genres do
      primary_key :id

      foreign_key :book_id, :books, on_delete: :cascade, null: false
      foreign_key :genre_id, :genres, on_delete: :cascade, null: false
    end
  end
end
