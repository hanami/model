Hanami::Model.migration do
  change do
    case Database.engine
    when :postgresql
      create_table :source_files do
        column :id,         "uuid",   primary_key: true, default: Hanami::Model::Sql.function(:uuid_generate_v4)
        column :name,       String,   null: false
        column :languages,  "text[]"
        column :metadata,   "jsonb", null: false
        column :json_info,  "json"
        column :content,    File,     null: false
        column :created_at, DateTime, null: false
        column :updated_at, DateTime, null: false
      end
    else
      create_table :source_files do
        primary_key :id
      end
    end
  end
end
