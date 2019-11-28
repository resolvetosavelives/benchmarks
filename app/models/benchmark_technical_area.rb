class BenchmarkTechnicalArea < ApplicationRecord
  include BenchmarkTechnicalAreaSeed

  has_many :benchmark_indicators

  default_scope { includes(:benchmark_indicators).order(:sequence) }

  def self.to_abbreviations
    all.map { |bta| "B#{bta.sequence}" }
  end
end
