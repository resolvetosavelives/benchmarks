class AssessmentIndicator < ApplicationRecord
  include AssessmentIndicatorSeed

  belongs_to :assessment_technical_area
  has_and_belongs_to_many :benchmark_indicators

  default_scope { order(:sequence) }

  ##
  # +indicator_short_code+ int such as p11 or re2
  def self.named_id_for_jee1(indicator_short_code)
    "jee1_ind_#{indicator_short_code}"
  end

  ##
  # +indicator_short_code+ int such as
  def self.named_id_for_spar_2018(indicator_short_code)
    "spar_2018_ind_#{indicator_short_code}"
  end

  ##
  # +indicator_short_code+ int such as
  def self.named_id_for_jee2(indicator_short_code)
    "jee2_ind_#{indicator_short_code}"
  end
end
