Hanami::Model.migration do
  change do
    case ENV['HANAMI_DATABASE_TYPE']
    when 'postgresql'
      # Postgres needs to know how to cast String into File
      execute "CREATE CAST (TEXT AS BYTEA) WITHOUT FUNCTION AS IMPLICIT;"
    end

    create_table :songs do
      column :title, String
      column :useless, String
      column :cover, String

      foreign_key :artist_id, :artists
      index :artist_id

      constraint(:useless_min_length) { length(title) > 2 }
    end

    alter_table :songs do
      add_primary_key :id

      add_column      :downloads_count, Integer
      set_column_type :cover,         File

      rename_column :title, :primary_title
      set_column_default :primary_title, 'Unknown title'

      add_foreign_key :album_id, :albums, on_delete: :cascade
      add_index :album_id
      drop_index :artist_id

      drop_foreign_key :artist_id

      add_constraint(:title_min_length) { length(primary_title) > 2 }

      add_unique_constraint [:album_id, :primary_title]

      drop_constraint :useless_min_length
      drop_column     :useless
    end
  end
end
