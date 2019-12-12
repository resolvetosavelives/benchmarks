class BenchmarkIndicatorActivity < ApplicationRecord
  include BenchmarkIndicatorActivitySeed

  belongs_to :benchmark_indicator
  has_many :plan_activity

  default_scope { order(:sequence) }

  # Note that these values are 0-indexed but in the DB they are 1-indexed
  ACTIVITY_TYPES = [
    "Advocacy",
    "Assessment and Data Use",
    "Coordination",
    "Designation",
    "Dissemination",
    "Financing",
    "Monitoring and Evaluation",
    "Planning and Strategy",
    "Procurement",
    "Program Implementation",
    "SimEx and AAR",
    "SOPs",
    "Surveillance",
    "Tool Development",
    "Training",
  ].freeze

  # defines how JSON will be formed with +to_json+ and +as_json+
  def attributes
    {
      id: nil,
      benchmark_indicator_id: nil,
      text: nil,
      level: nil,
      sequence: nil,
    }
  end
end
