class AssessmentScore < ApplicationRecord
  belongs_to :assessment
  belongs_to :assessment_indicator
end
