# frozen_string_literal: true

Hanami::Model.migration do
  up do
    add_column :reviews, :rating, "integer", default: 0
  end

  down do
    drop_column :reviews, :rating
  end
end
