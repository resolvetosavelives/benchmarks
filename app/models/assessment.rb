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
          includes(:assessment_publication).where(
            country_alpha3: country_alpha3,
            assessment_publication_id: assessment_publication_id
          )
        }

  def self.deep_load(country_alpha3, assessment_publication_id)
    includes({ scores: :assessment_indicator })
      .with_publication(country_alpha3, assessment_publication_id)
      .first
  end

  validates :assessment_publication, :country, presence: true
  delegate :jee?, :spar?, to: :assessment_publication
end
