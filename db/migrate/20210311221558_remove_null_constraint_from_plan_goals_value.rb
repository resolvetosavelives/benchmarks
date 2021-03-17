class RemoveNullConstraintFromPlanGoalsValue < ActiveRecord::Migration[5.2]
  def up
    change_column :plan_goals, :value, :integer, null: true
  end

  def down
    change_column :plan_goals, :value, :integer, null: false
  end
end
