class BenchmarkTechnicalArea < ApplicationRecord
  include BenchmarkTechnicalAreaSeed

  has_many :benchmark_indicators

  default_scope { includes(:benchmark_indicators).order(:sequence) }

  def self.to_abbreviation_map
    abbreviation_map = {}
    all.each do |bta|
      abbreviation_map[bta.to_abbreviation] = bta.id
    end
    abbreviation_map
  end

  def to_abbreviation
    "B#{sequence}"
  end

  def attributes
    {
        id: nil,
        text: nil,
        sequence: nil
    }
  end
end
