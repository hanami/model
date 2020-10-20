# frozen_string_literal: true
Hanami::Model.migration do
  up do
    create_table :reviews do
      primary_key :id
      column :title, String, null: false
    end
  end

  down do
    drop_table :reviews
  end
end
