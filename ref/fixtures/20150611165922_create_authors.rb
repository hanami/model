# This file is intentionally placed outside of test/fixtures/migrations to
# simulate a pending migration.
Hanami::Model.migration do
  change do
    create_table :authors do
      primary_key :id
      column :name, String
    end
  end
end
