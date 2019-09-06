class BenchmarksFixture
  attr_reader :fixture
  def initialize
    @fixture = JSON.load File.open './app/fixtures/benchmarks.json'
  end

  def capacities
    @fixture['benchmarks'].keys.map(&:to_i).sort.map do |k|
      ({ id: k.to_s, name: @fixture['benchmarks'][k.to_s]['name'] })
    end
  end

  def capacity_text(capacity_id)
    capacity_id_str = String(capacity_id)
    unless @fixture['benchmarks'][capacity_id_str]
      raise (ArgumentError.new "Invalid capacity: #{capacity_id_str}")
    end
    @fixture['benchmarks'][capacity_id_str]['name']
  end

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

  def type_code_text(group, code)
    raise ArgumentError unless @fixture.dig('type_codes', group)
    raise ArgumentError unless @fixture.dig('type_codes', group, code)
    @fixture.dig('type_codes', group, code)
  end

  def type_code_1s
    @fixture.dig('type_codes', '1')
  end
end
