class Country < ApplicationRecord
  include CountrySeed

  has_many :assessments, foreign_key: "country_alpha3", primary_key: "alpha3"
  has_many :plans

  default_scope { order(:name) }
  scope :all_assessed, -> { joins(:assessments).distinct.all }

  def attributes
    {
        id: nil,
        name: nil,
        alpha3: nil
    }
  end

  def has_jee1?
    assessments.any? { |a| a.jee1? }
  end

  def has_spar_2018?
    assessments.any? { |a| a.spar_2018? }
  end
end
