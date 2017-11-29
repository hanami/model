# frozen_string_literal: true

Hanami::Model.migration do
  change do
    create_table :labels do
      column :id, Integer
    end
  end
end
