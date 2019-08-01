# frozen_string_literal: true

Hanami::Model.migration do
  change do
    case ENV["HANAMI_DATABASE_TYPE"]
    when "sqlite"
      create_table :songs do
        column :title, String
        column :useless, String

        foreign_key :artist_id, :artists
        index :artist_id

        add_constraint(:useless_min_length) { char_length(useless) > 2 }
      end

      alter_table :songs do
        add_primary_key :id

        add_column      :downloads_count, Integer
        set_column_type :useless,         File

        rename_column :title, :primary_title
        set_column_default :primary_title, "Unknown title"

        # add_index :album_id
        # drop_index :artist_id

        # add_foreign_key :album_id, :albums, on_delete: :cascade
        # drop_foreign_key :artist_id

        # add_constraint(:title_min_length) { char_length(title) > 2 }

        # add_unique_constraint [:album_id, :title]

        drop_constraint :useless_min_length
        drop_column     :useless
      end
    when "postgresql"
      create_table :songs do
        column :title, String
        column :useless, String

        foreign_key :artist_id, :artists
        index :artist_id

        # add_constraint(:useless_min_length) { char_length(useless) > 2 }
      end

      alter_table :songs do
        add_primary_key :id

        add_column    :downloads_count, Integer
        # set_column_type :useless, File

        rename_column :title, :primary_title
        set_column_default :primary_title, "Unknown title"

        # add_index :album_id
        # drop_index :artist_id

        # add_foreign_key :album_id, :albums, on_delete: :cascade
        # drop_foreign_key :artist_id

        # add_constraint(:title_min_length) { char_length(title) > 2 }

        # add_unique_constraint [:album_id, :title]

        # drop_constraint :useless_min_length
        drop_column :useless
      end
    end
  end
end
