class AssessmentPublication < ApplicationRecord
  NAMED_IDS = %w[jee1 spar_2018 jee2].freeze
  include AssessmentPublicationSeed

  has_many :assessment_technical_areas
  has_many :assessments

  scope :jee1, -> { where(named_id: NAMED_IDS.first).first }
  scope :spar_2018, -> { where(named_id: NAMED_IDS.second).first }

  def jee1?
    named_id.eql? NAMED_IDS.first
  end

  def spar_2018?
    named_id.eql? NAMED_IDS.second
  end

  def type_description
    "#{abbrev} #{revision}"
  end
end
