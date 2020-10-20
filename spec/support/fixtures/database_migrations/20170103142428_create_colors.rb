# frozen_string_literal: true
Hanami::Model.migration do
  change do
    case Database.engine
    when :postgresql
      extension :pg_enum
      create_enum :rainbow, %w[red orange yellow green blue indigo violet]

      create_table :colors do
        primary_key :id

        column :name, :rainbow, null: false

        column :created_at, DateTime, null: false
        column :updated_at, DateTime, null: false
      end
    else
      create_table :colors do
        primary_key :id
      end
    end
  end
end
