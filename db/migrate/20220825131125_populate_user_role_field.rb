class PopulateUserRoleField < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      UPDATE users
        SET role = 'user'
      WHERE role IS NULL
        OR  role NOT IN ('user', 'admin')
    SQL
  end
end
