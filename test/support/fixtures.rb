require 'hanami/model/migrator'

class User
  include Hanami::Entity
end

class UserRepository
  include Hanami::Repository

  def by_name(name)
    where(name: name)
  end
end

Hanami::Model.configure do
  adapter :sql, 'sqlite::memory'
end

Hanami::Model.migration do
  change do
    create_table :users do
      primary_key :id
      column :name, String
    end
  end
end.run

Hanami::Model.load!
