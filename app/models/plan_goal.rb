class PlanGoal < ApplicationRecord
  belongs_to :plan
  belongs_to :assessment_indicator
  belongs_to :benchmark_indicator
end
