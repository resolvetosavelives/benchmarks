class Country < ApplicationRecord
  include CountrySeed

  has_many :assessments, foreign_key: "country_alpha3", primary_key: "alpha3"
  has_many :assessment_publications, through: :assessments

  default_scope { order(:name) }
  scope :all_assessed, -> { joins(:assessments).distinct.all }
  scope :with_assessments_and_publication,
        lambda { |country_id|
          includes(assessments: :assessment_publication)
            .where(id: country_id)
            .first
        }

  def publications_for_selection
    assessments
      .where(clean_slate: false)
      .includes(:assessment_publication)
      .map(&:assessment_publication)
      .to_a
      .tap { |pubs| pubs.reject!(&:jee1?) if pubs.any?(&:jee2?) }
  end

  def as_json(options = {})
    super(options.reverse_merge(only: %i[id name alpha3]))
  end
end
