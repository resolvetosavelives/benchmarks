class PlanActivity < ApplicationRecord
  belongs_to :plan
  belongs_to :benchmark_indicator_activity
  belongs_to :benchmark_indicator
  belongs_to :benchmark_technical_area

  default_scope do
    includes(:benchmark_indicator_activity).order(
      "benchmark_indicator_activities.level",
      "benchmark_indicator_activities.sequence",
    )
  end

  delegate :text, :sequence, to: :benchmark_indicator_activity

  def self.new_for_benchmark_activity(benchmark_indicator_activity)
    new(
      benchmark_indicator_activity: benchmark_indicator_activity,
      benchmark_indicator_id:
        benchmark_indicator_activity.benchmark_indicator_id,
      benchmark_technical_area_id:
        benchmark_indicator_activity.benchmark_technical_area_id,
    )
  end
end
