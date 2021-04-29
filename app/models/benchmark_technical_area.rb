class BenchmarkTechnicalArea < ApplicationRecord
  include BenchmarkTechnicalAreaSeed

  has_many :benchmark_indicators

  default_scope { order(:sequence) }

  def full_name
    "#{sequence}. #{text}"
  end

  def as_json(options = {})
    super(options.reverse_merge(only: %i[id text sequence]))
  end
end
