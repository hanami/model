# frozen_string_literal: true
Hanami::Model.migration do
  change do
    create_table :artists do
      primary_key :id
    end

    create_table :albums do
      primary_key :id
      foreign_key :artist_id, :artists, on_delete: :cascade, null: false, type: :integer
    end
  end
end
