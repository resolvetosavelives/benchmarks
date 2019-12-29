# An Assessment represents the scores of the independent assessment that
# countries can run. It can be of any type, but the known ones are jee1, jee2,
# and spar_2018.
class Assessment < ApplicationRecord
  include AssessmentSeed

  # NB: the association is: assessments.country_alpha3 => countries.alpha3
  belongs_to :country, foreign_key: "country_alpha3", primary_key: "alpha3"

  default_scope { includes(:country).order("country_alpha3", "assessment_type") }

  def self.all_for_select_menu
    all
  end
end
