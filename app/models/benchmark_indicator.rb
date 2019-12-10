class BenchmarkIndicator < ApplicationRecord
  belongs_to :benchmark_technical_area
  has_many :activities, class_name: "BenchmarkIndicatorActivity"
  has_and_belongs_to_many :assessment_indicators

  default_scope { order(:sequence) }

  def activities_excluded_from(activity_ids)
    excluded_ids = (activities.map(&:id).to_set - activity_ids.to_set).to_a
    activities.select {|a| excluded_ids.include?(a.id) }
  end
end
