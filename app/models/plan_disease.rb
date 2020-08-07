class PlanDisease < ApplicationRecord
  belongs_to :plan
  belongs_to :disease
end
