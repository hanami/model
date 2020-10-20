# frozen_string_literal: true
Hanami::Model.migration do
  change do
    drop_table?   :warehouses
    create_table? :warehouses do
      primary_key :id
      column :name,       String
      column :code,       String
      column :created_at, DateTime,  null: false
      column :updated_at, DateTime,  null: false
    end
  end
end
