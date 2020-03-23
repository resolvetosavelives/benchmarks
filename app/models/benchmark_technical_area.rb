class BenchmarkTechnicalArea < ApplicationRecord
  include BenchmarkTechnicalAreaSeed

  has_many :benchmark_indicators

  default_scope { order(:sequence) }

  def attributes
    { id: nil, text: nil, sequence: nil }
  end
end
