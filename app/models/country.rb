class Country < ApplicationRecord
  include CountrySeed

  has_many :assessments, foreign_key: "country_alpha3", primary_key: "alpha3"

  default_scope { order(:name) }
  scope :all_assessed, -> { joins(:assessments).distinct.all }
  scope :with_assessments_and_publication,
        lambda { |country_id|
          includes(assessments: :assessment_publication).where(id: country_id)
            .first
        }

  def attributes
    { id: nil, name: nil, alpha3: nil }
  end

  def has_jee1?
    assessments.any?(&:jee1?)
  end

  def has_spar_2018?
    assessments.any?(&:spar_2018?)
  end
end
