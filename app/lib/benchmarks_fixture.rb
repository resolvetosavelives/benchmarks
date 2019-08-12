class BenchmarksFixture
  def initialize
    @fixture =
      JSON.load File.open './app/fixtures/benchmarks_and_activities.json'
  end

  def benchmark_text(benchmark_id)
    @fixture[benchmark_id]['benchmark']
  end

  def goal_activities(benchmark_id, score, goal)
    raise ArgumentError unless @fixture[benchmark_id]

    unless goal.between?(2, 5)
      raise RangeError.new 'goal is not between 2 and 5'
    end
    unless score.between?(1, 5)
      raise RangeError.new 'score is not between 2 and 5'
    end
    raise ArgumentError.new 'score is > goal' unless score <= goal

    return(
      (score + 1..goal).reduce([]) do |acc, level|
        acc.concat @fixture[benchmark_id]['capacity'][level.to_s]
        acc
      end
    )
  end

  def capacity_activities(benchmark_id, level)
    unless level.between?(2, 5)
      raise RangeError.new 'level is not between 2 and 5'
    end
    return @fixture[benchmark_id]['capacity'][level.to_s]
  end
end
