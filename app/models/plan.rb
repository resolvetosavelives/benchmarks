# A draft plan. This consists of the assessment goals and a large activity map,
# organized by Technical Capacity and Benchmark Indicator. The activity_map
# field is an ActivityMap object.
class Plan < ApplicationRecord
  belongs_to :user, optional: true

  def activity_map
    ActivityMap.new self[:activity_map]
  end

  def all_activities(benchmarks = BenchmarksFixture.new)
    activities = []
    return activities if self[:activity_map].blank?

    benchmarks.capacities.map do |capacity|
      benchmarks.capacity_benchmarks(capacity[:id]).map do |benchmark|
        self.activity_map.benchmark_activities(benchmark[:id]).map do |key, val|
          activities << key["text"]
        end
      end
    end.flatten
    activities
  end

end
