class AddIndexToUsersRole < ActiveRecord::Migration[7.1]
  def change
    add_index :users, :role
  end
end
