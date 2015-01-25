class RemoveComments < Lotus::Model::Migration
  def up
    drop_table :comments
  end

  def down
    create_table :comments do
      primary_key :id
      String :content
    end
  end
end
