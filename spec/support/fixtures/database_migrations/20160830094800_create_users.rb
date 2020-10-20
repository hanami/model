# frozen_string_literal: true
Hanami::Model.migration do
  change do
    drop_table?   :users
    create_table? :users do
      primary_key :id
      column :name,           String
      column :email,          String
      column :age,            Integer,   null: false, default: 19
      column :comments_count, Integer,   null: false, default: 0
      column :active,         TrueClass, null: false, default: true
      column :created_at,     DateTime,  null: false
      column :updated_at,     DateTime,  null: false

      check { age > 18 }
      constraint(:comments_count_constraint) { comments_count >= 0 }
    end

    add_index :users, :email, unique: true
  end
end
