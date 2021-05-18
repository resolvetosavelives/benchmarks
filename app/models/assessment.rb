# An Assessment represents the scores of the independent assessment that
# countries can run.
class Assessment < ApplicationRecord
  include AssessmentSeed

  belongs_to :assessment_publication

  # NB: the association is: assessments.country_alpha3 => countries.alpha3
  belongs_to :country, foreign_key: "country_alpha3", primary_key: "alpha3"
  has_many :scores, class_name: "AssessmentScore"
  has_many :plans
  default_scope { order("country_alpha3") }

  scope :with_publication,
        lambda { |country_alpha3, assessment_publication_id|
          includes(:assessment_publication)
            .find_by_country_alpha3_and_assessment_publication_id(
            country_alpha3,
            assessment_publication_id
          )
        }

  scope :deep_load,
        lambda { |country_alpha3, assessment_publication_id|
          includes({ scores: :assessment_indicator }).with_publication(
            country_alpha3,
            assessment_publication_id
          )
        }


  def self.spar_2018_named_id
    "spar_2018"
  end

  validates :assessment_publication, :country, presence: true
  delegate :jee?, :spar?, to: :assessment_publication
end
