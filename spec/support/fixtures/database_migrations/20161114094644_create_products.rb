Hanami::Model.migration do
  change do
    case Database.engine
    when :postgresql
      create_table :products do
        primary_key :id
        column :name,       String
        column :categories, "text[]"
      end
    else
      create_table :products do
        primary_key :id
      end
    end
  end
end
