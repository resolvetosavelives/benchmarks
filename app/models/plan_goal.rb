class PlanGoal < ApplicationRecord
  belongs_to :plan
  belongs_to :assessment_indicator
  belongs_to :benchmark_indicator

  # NB: intentionally omitting the +assessment_indicator_id+ because most of the time its not needed and would cause confusion.
  def attributes
    {
        id: nil,
        plan_id: nil,
        value: nil,
        benchmark_indicator_id: nil,
    }
  end
end
