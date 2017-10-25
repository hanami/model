Hanami::Model.migration do
  change do
    drop_table?   :categories
    create_table? :categories do
      primary_key :id
      column :name, String
    end
    drop_table? :book_ontologies
    create_table? :book_ontologies do
      primary_key :id

      foreign_key :book_id, :books, on_delete: :cascade, null: false
      foreign_key :category_id, :categories, on_delete: :cascade, null: false
    end
  end
end
