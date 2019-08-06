class Plan < ApplicationRecord
  def activities
    fixture = JSON.load(File.open 'app/fixtures/benchmarks_and_activities.json')
    capacity_map.reduce({}) do |acc, (benchmark_id, capacity_id)|
      acc[benchmark_id] = fixture[benchmark_id]["capacity"][capacity_id]
      acc
    end
  end
end
