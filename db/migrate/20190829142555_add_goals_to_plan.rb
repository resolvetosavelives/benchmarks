class AddGoalsToPlan < ActiveRecord::Migration[5.2]
  def change
    add_column :plans, :goals, :jsonb
  end
end
