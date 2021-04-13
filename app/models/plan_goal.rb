class PlanGoal < ApplicationRecord
  belongs_to :plan
  belongs_to :assessment_indicator
  belongs_to :benchmark_indicator

  # NB: intentionally omitting the +assessment_indicator_id+ because most of the time its not needed and would cause confusion.
  def as_json(options = {})
    super(
      options.reverse_merge(only: %i[id plan_id value benchmark_indicator_id])
    )
  end
end
