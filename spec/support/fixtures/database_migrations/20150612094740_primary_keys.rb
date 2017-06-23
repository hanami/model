Hanami::Model.migration do
  change do
    create_table :primary_keys_1 do
      primary_key :id
    end

    create_table :primary_keys_2 do
      column :name, String, primary_key: true
    end

    create_table :primary_keys_3 do
      column :group_id, Integer
      column :position, Integer

      primary_key [:group_id, :position], name: :primary_keys_3_pk
    end
  end
end
