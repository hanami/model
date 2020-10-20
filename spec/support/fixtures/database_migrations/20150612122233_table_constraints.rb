Hanami::Model.migration do
  change do
    case ENV["HANAMI_DATABASE_TYPE"]
    when "sqlite"
      create_table :table_constraints do
        column :age, Integer
        constraint(:age_constraint) { age > 18 }

        column :role, String
        check %(role IN("contributor", "manager", "owner"))
      end
    when "postgresql"
      create_table :table_constraints do
        column :age, Integer
        constraint(:age_constraint) { age > 18 }

        column :role, String
        check %(role IN('contributor', 'manager', 'owner'))
      end
    when "mysql"
      create_table :table_constraints do
        column :age, Integer
        constraint(:age_constraint) { age > 18 }

        column :role, String
        check %(role IN("contributor", "manager", "owner"))
      end
    end
  end
end
