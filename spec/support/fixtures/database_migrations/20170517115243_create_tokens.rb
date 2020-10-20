# frozen_string_literal: true
Hanami::Model.migration do
  change do
    drop_table?   :tokens
    create_table? :tokens do
      primary_key :id
      column :token, String
    end
  end
end
