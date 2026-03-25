class AddIndexToUsersRole < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    if connection.adapter_name == 'PostgreSQL'
      add_index :users, :role, algorithm: :concurrently, if_not_exists: true
    else
      add_index :users, :role, if_not_exists: true
    end
  end
end
