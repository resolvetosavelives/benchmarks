class PlanBenchmarkIndicator < ApplicationRecord
  belongs_to :plan
  belongs_to :assessment_indicator
  belongs_to :benchmark_indicator

  default_scope { includes(:benchmark_indicator) }
end
