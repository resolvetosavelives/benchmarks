# A wrapper around benchmarks.json
#
# This eases the difficulty of accessing the data in the benchmarks fixture,
# and provides a barrier so that future changes in the fixture itself don't
# trigger changes across all of the code.
class BenchmarksFixture
  attr_reader :fixture
  def initialize
    @fixture = JSON.load File.open './app/fixtures/benchmarks.json'
  end

  # Get a sorted list of all of the capacity ids.
  def capacities
    @fixture['benchmarks'].keys.map(&:to_i).sort.map do |k|
      ({ id: k.to_s, name: @fixture['benchmarks'][k.to_s]['name'] })
    end
  end

  # Get the text for a capacity based on its id. The parameter can be either a
  # number or a string. This will raise ArgumentError if the capacity does not
  # actually exist in the system.
  def capacity_text(capacity_id)
    capacity_id_str = String(capacity_id)
    unless @fixture['benchmarks'][capacity_id_str]
      raise (ArgumentError.new "Invalid capacity: #{capacity_id_str}")
    end
    @fixture['benchmarks'][capacity_id_str]['name']
  end

  # Get the indicator text for a benchmark. The parameter must be a
  # BenchmarkId. This function will raise ArgumentError if either the capacity
  # component is out of range, or the indicator component is out of range for
  # the capacity.
  def indicator_text(benchmark_id)
    unless @fixture['benchmarks'][benchmark_id.capacity_s]
      raise (ArgumentError.new "Invalid capacity: #{benchmark_id.capacity_s}")
    end
    unless @fixture['benchmarks'][benchmark_id.capacity_s]['indicators'][
           benchmark_id.indicator_s
         ]
      raise (ArgumentError.new "Invalid indicator: #{benchmark_id.indicator_s}")
    end
    @fixture['benchmarks'][benchmark_id.capacity_s]['indicators'][
      benchmark_id.indicator_s
    ][
      'indicator'
    ]
  end

  # Get the objective text for an benchmark. The parameter must be a
  # BenchmarkId. This function will be raise ArgumentError if the capacity or
  # indicator is out of range.
  def objective_text(benchmark_id)
    unless @fixture['benchmarks'][benchmark_id.capacity_s]
      raise (ArgumentError.new "Invalid capacity: #{benchmark_id.capacity_s}")
    end
    unless @fixture['benchmarks'][benchmark_id.capacity_s]['indicators'][
           benchmark_id.indicator_s
         ]
      raise (ArgumentError.new "Invalid indicator: #{benchmark_id.indicator_s}")
    end
    @fixture['benchmarks'][benchmark_id.capacity_s]['indicators'][
      benchmark_id.indicator_s
    ][
      'objective'
    ]
  end

  # Get a list all activities to raise a benchmark from score to goal.
  # benchmark_id must be a BenchmarkId, score and goal must both be numbers
  # between 1 and 5, and goal must match or exceed score.
  def goal_activities(benchmark_id, score, goal)
    unless @fixture['benchmarks'][benchmark_id.capacity_s]
      raise (ArgumentError.new "Invalid capacity: #{benchmark_id.capacity_s}")
    end
    unless @fixture['benchmarks'][benchmark_id.capacity_s]['indicators'][
           benchmark_id.indicator_s
         ]
      raise (ArgumentError.new "Invalid indicator: #{benchmark_id.indicator_s}")
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
        acc.concat @fixture['benchmarks'][benchmark_id.capacity_s][
                     'indicators'
                   ][
                     benchmark_id.indicator_s
                   ][
                     'activities'
                   ][
                     level.to_s
                   ]
        acc
      end
    )
  end

  # Get all of the activities for a particular level of the specified
  # benchmark. benchmark_id must be a BenchmarkId, and level must be a number
  # between 2 and 5.
  def level_activities(benchmark_id, level)
    unless @fixture['benchmarks'][benchmark_id.capacity_s]
      raise (ArgumentError.new "Invalid capacity: #{benchmark_id.capacity_s}")
    end
    unless @fixture['benchmarks'][benchmark_id.capacity_s]['indicators'][
           benchmark_id.indicator_s
         ]
      raise (ArgumentError.new "Invalid indicator: #{benchmark_id.indicator_s}")
    end
    unless level.value.between?(2, 5)
      raise RangeError.new 'level is not between 2 and 5'
    end
    return(
      @fixture['benchmarks'][benchmark_id.capacity_s]['indicators'][
        benchmark_id.indicator_s
      ][
        'activities'
      ][
        level.value.to_s
      ]
    )
  end

  # Retrieve a list of the text of all of the activities for a benchmark.
  # benchmark_id must be a BenchmarkId. This is used to provide autocomplete
  # for the draft plan page.
  def activity_texts(benchmark_id)
    @fixture.dig(
      'benchmarks',
      benchmark_id.capacity_s,
      'indicators',
      benchmark_id.indicator_s,
      'activities'
    )
      .values
      .flatten
      .map { |a| a['text'] }.uniq
  end

  # Get the text for a type code. Type codes come in groups (1, 2, 3, though
  # only 1 is currently supported).
  def type_code_text(group, code)
    raise ArgumentError unless @fixture.dig('type_codes', group)
    raise ArgumentError unless @fixture.dig('type_codes', group, code)
    @fixture.dig('type_codes', group, code)
  end

  def type_code_1s
    @fixture.dig('type_codes', '1')
  end
end
