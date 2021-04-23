class BenchmarkIndicator < ApplicationRecord
  include BenchmarkIndicatorSeed

  belongs_to :benchmark_technical_area
  has_many :actions, class_name: "BenchmarkIndicatorAction"
  has_and_belongs_to_many :assessment_indicators

  default_scope { order(:sequence) }

  def actions_excluded_from(action_ids)
    excluded_ids = (actions.map(&:id).to_set - action_ids.to_set).to_a
    actions.select { |a| excluded_ids.include?(a.id) }
  end

  def actions_for(score: 0, goal: 0, disease_ids: [])
    actions.for_diseases_and_levels(
      low: score,
      high: goal,
      disease_ids: disease_ids
    )
  end
end
