class AssessmentPublication < ApplicationRecord
  NAMED_IDS = %w[jee1 spar_2018 jee2].freeze
  include AssessmentPublicationSeed

  has_many :assessment_technical_areas
  has_many :assessments

  def self.jee1
    self.find_by(named_id: "jee1")
  end

  def self.jee2
    self.find_by(named_id: "jee2")
  end

  def self.spar
    self.find_by(named_id: "spar_2018")
  end

  def type_description
    "#{abbrev} #{revision}"
  end

  def jee?
    %w[jee1 jee2].include?(named_id)
  end

  def spar?
    %w[spar_2018].include?(named_id)
  end
end
