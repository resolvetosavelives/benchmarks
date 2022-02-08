class AllowUsersWithAzureIdentity < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :azure_identity, :string
    add_index :users, :azure_identity, unique: true
    change_column_null :users, :email, true
    change_column_null :users, :role, true
    change_column_null :users, :encrypted_password, true
  end
end
