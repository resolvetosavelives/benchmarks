class AssessmentPublication < ApplicationRecord
  include AssessmentPublicationSeed

  has_many :assessment_technical_areas
end
