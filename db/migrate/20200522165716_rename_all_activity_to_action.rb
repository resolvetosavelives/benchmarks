class RenameAllActivityToAction < ActiveRecord::Migration[5.2]
  def change
    rename_index :benchmark_indicator_activities, :index_benchmark_indicator_activities_on_benchmark_indicator_id, :index_benchmark_indicator_actions_on_benchmark_indicator_id
    rename_index :plan_activities, :index_plan_activities_on_plan_id, :index_plan_actions_on_plan_id

    rename_column :plan_activities, :benchmark_indicator_activity_id, :benchmark_indicator_action_id
    rename_column :benchmark_indicator_activities, :activity_types, :action_types

    rename_table :benchmark_indicator_activities, :benchmark_indicator_actions
    rename_table :plan_activities, :plan_actions
  end
end
