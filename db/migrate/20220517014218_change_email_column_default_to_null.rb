class ChangeEmailColumnDefaultToNull < ActiveRecord::Migration[7.0]
  class MigrationUser < ApplicationRecord
    self.table_name = :users
  end

  def change
    change_column_default :users, :email, nil
    MigrationUser.where(email: "").update_all(email: nil)
  end
end
