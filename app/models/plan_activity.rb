class PlanActivity < ApplicationRecord
  belongs_to :plan
  belongs_to :benchmark_indicator_activity

  default_scope { includes(:benchmark_indicator_activity).order("benchmark_indicator_activities.level", "benchmark_indicator_activities.sequence") }

  delegate :text, :sequence, to: :benchmark_indicator_activity

  def self.new_for_benchmark_activity(benchmark_indicator_activity)
    new(
      benchmark_indicator_activity: benchmark_indicator_activity,
      benchmark_indicator_id: benchmark_indicator_activity.benchmark_indicator_id
    )
  end
end
