Lotus::Model.migration do
  change do
    create_table :table_constraints do
      column :age, Integer
      constraint(:age_constraint) { age > 18 }

      column :role, String
      check %(role IN("contributor", "manager", "owner"))
    end
  end
end
