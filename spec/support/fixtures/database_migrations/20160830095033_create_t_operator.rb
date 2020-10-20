# frozen_string_literal: true
Hanami::Model.migration do
  change do
    drop_table?   :t_operator
    create_table? :t_operator do
      primary_key :operator_id
      column :s_name, String
    end
  end
end
