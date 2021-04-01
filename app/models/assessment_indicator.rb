class AssessmentIndicator < ApplicationRecord
  include AssessmentIndicatorSeed

  belongs_to :assessment_technical_area
  has_and_belongs_to_many :benchmark_indicators

  default_scope { order(:sequence) }

  def self.find_by_code!(name, code)
    find_by_named_id!("#{name}_ind_#{code}")
  end
end
