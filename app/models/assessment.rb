# An Assessment represents the scores of the independent assessment that
# countries can run.
class Assessment < ApplicationRecord
  include AssessmentSeed

  belongs_to :assessment_publication
  # NB: the association is: assessments.country_alpha3 => countries.alpha3
  belongs_to :country, foreign_key: "country_alpha3", primary_key: "alpha3"
  has_many :scores, class_name: "AssessmentScore"
  has_many :plans
  default_scope { includes(:country).order("country_alpha3") }

  delegate :jee1?, :spar_2018?, :type_description, to: :assessment_publication

  validates :assessment_publication, :country, presence: true

  def self.spar_2018_named_id
    "spar_2018"
  end

  def attributes
    {
        id: nil,
        assessment_type: nil,
        country_alpha3: nil
    }
  end
end
