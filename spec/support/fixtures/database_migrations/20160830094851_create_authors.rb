# frozen_string_literal: true

Hanami::Model.migration do
  change do
    drop_table?   :authors
    create_table? :authors do
      primary_key :id
      column :name,       String
      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end
  end
end
