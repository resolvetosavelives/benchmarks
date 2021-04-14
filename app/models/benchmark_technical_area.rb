class BenchmarkTechnicalArea < ApplicationRecord
  include BenchmarkTechnicalAreaSeed

  has_many :benchmark_indicators

  default_scope { order(:sequence) }

  def as_json(options = {})
    super(options.reverse_merge(only: %i[id text sequence]))
  end
end
