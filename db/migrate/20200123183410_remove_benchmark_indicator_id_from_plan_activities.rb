class RemoveBenchmarkIndicatorIdFromPlanActivities < ActiveRecord::Migration[5.2]
  def change
    remove_column :plan_activities, :benchmark_indicator_id
    remove_column :plan_activities, :sequence
  end
end
