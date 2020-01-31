class AddMoreIdsToPlanActivityForPerformance < ActiveRecord::Migration[5.2]
  def change
    add_column :plan_activities, :benchmark_indicator_id, :integer
    add_column :plan_activities, :benchmark_technical_area_id, :integer
    add_foreign_key :plan_activities, :benchmark_indicators
    add_foreign_key :plan_activities, :benchmark_technical_areas
  end
end
