class BenchmarksFixture
  def initialize
    @fixture =
      JSON.load File.open './app/fixtures/benchmarks_and_activities.json'
  end

  def benchmark_text(benchmark_id)
    @fixture[benchmark_id]['benchmark']
  end

  def goal_activities(benchmark_id, score, goal)
    unless @fixture[benchmark_id]
      raise ArgumentError.new "invalid benchmark: #{benchmark_id}"
    end

    unless goal.value.between?(2, 5)
      raise RangeError.new 'goal is not between 2 and 5'
    end
    unless score.value.between?(1, 5)
      raise RangeError.new 'score is not between 1 and 5'
    end
    raise ArgumentError.new 'score is > goal' unless score <= goal

    return(
      (score.value + 1..goal.value).reduce([]) do |acc, level|
        acc.concat @fixture[benchmark_id]['capacity'][level.to_s]
        acc
      end
    )
  end

  def capacity_activities(benchmark_id, level)
    unless level.value.between?(2, 5)
      raise RangeError.new 'level is not between 2 and 5'
    end
    return @fixture[benchmark_id]['capacity'][level.value.to_s]
  end
end
