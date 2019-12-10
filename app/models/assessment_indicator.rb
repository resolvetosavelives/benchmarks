class AssessmentIndicator < ApplicationRecord
  include AssessmentIndicatorSeed

  belongs_to :assessment_technical_area
  has_and_belongs_to_many :benchmark_indicators

  default_scope { order(:sequence) }
end
