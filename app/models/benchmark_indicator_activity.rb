class BenchmarkIndicatorActivity < ApplicationRecord

  belongs_to :benchmark_indicator
  has_many :plan_activity

  default_scope { order(:sequence) }

  # defines how JSON will be formed with +to_json+ and +as_json+
  def attributes
    {
        id: nil,
        benchmark_indicator_id: nil,
        text: nil,
        level: nil,
        sequence: nil
    }
  end
end
