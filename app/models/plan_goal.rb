class PlanGoal < ApplicationRecord
  belongs_to :plan
  belongs_to :assessment_indicator
  belongs_to :benchmark_indicator

  default_scope { includes(:assessment_indicator) }
end
