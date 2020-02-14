class BenchmarkTechnicalArea < ApplicationRecord
  include BenchmarkTechnicalAreaSeed

  has_many :benchmark_indicators

  default_scope { order(:sequence) }

  def self.to_abbreviation_map(benchmark_technical_areas = nil)
    abbreviation_map = {}
    technical_areas = benchmark_technical_areas.blank? ? all: benchmark_technical_areas
    technical_areas.each do |bta|
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
