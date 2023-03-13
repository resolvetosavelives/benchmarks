class PlanAction < ApplicationRecord
  belongs_to :plan
  belongs_to :benchmark_indicator_action
  belongs_to :benchmark_indicator
  belongs_to :benchmark_technical_area

  default_scope do
    includes(:benchmark_indicator_action).order(
      "benchmark_indicator_actions.level",
      "benchmark_indicator_actions.sequence"
    )
  end

  delegate :text, :sequence, to: :benchmark_indicator_action

  def self.new_for_benchmark_action(benchmark_indicator_action)
    new(
      benchmark_indicator_action: benchmark_indicator_action,
      benchmark_indicator_id: benchmark_indicator_action.benchmark_indicator_id,
      benchmark_technical_area_id:
        benchmark_indicator_action.benchmark_technical_area_id
    )
  end
end
