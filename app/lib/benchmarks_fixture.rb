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
    capacity_id = String(capacity_id)
    unless @fixture['benchmarks'][capacity_id]
      raise (ArgumentError.new "Invalid capacity: #{capacity_id}")
    end
    @fixture['benchmarks'][capacity_id]['name']
  end

  def indicator_text(id)
    id_ = id.class == String ? (BenchmarkId.from_s id) : id
    capacity_id = String(id_.capacity)
    indicator_id = String(id_.indicator)
    unless @fixture['benchmarks'][capacity_id]
      raise (ArgumentError.new "Invalid capacity: #{capacity_id}")
    end
    unless @fixture['benchmarks'][capacity_id]['indicators'][indicator_id]
      raise (ArgumentError.new "Invalid indicator: #{indicator_id}")
    end
    @fixture['benchmarks'][capacity_id]['indicators'][indicator_id]['indicator']
  end

  def objective_text(id)
    id_ = id.class == String ? (BenchmarkId.from_s id) : id
    capacity_id = String(id_.capacity)
    indicator_id = String(id_.indicator)
    unless @fixture['benchmarks'][capacity_id]
      raise (ArgumentError.new "Invalid capacity: #{capacity_id}")
    end
    unless @fixture['benchmarks'][capacity_id]['indicators'][indicator_id]
      raise (ArgumentError.new "Invalid indicator: #{indicator_id}")
    end
    @fixture['benchmarks'][capacity_id]['indicators'][indicator_id]['objective']
  end

  def goal_activities(id, score, goal)
    id_ = id.class == String ? (BenchmarkId.from_s id) : id
    capacity_id = String(id_.capacity)
    indicator_id = String(id_.indicator)
    unless @fixture['benchmarks'][capacity_id]
      raise (ArgumentError.new "Invalid capacity: #{capacity_id}")
    end
    unless @fixture['benchmarks'][capacity_id]['indicators'][indicator_id]
      raise (ArgumentError.new "Invalid indicator: #{indicator_id}")
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
        acc.concat @fixture['benchmarks'][capacity_id]['indicators'][
                     indicator_id
                   ][
                     'activities'
                   ][
                     level.to_s
                   ]
        acc
      end
    )
  end

  def level_activities(id, level)
    id_ = id.class == String ? (BenchmarkId.from_s id) : id
    capacity_id = String(id_.capacity)
    indicator_id = String(id_.indicator)
    unless @fixture['benchmarks'][capacity_id]
      raise (ArgumentError.new "Invalid capacity: #{capacity_id}")
    end
    unless @fixture['benchmarks'][capacity_id]['indicators'][indicator_id]
      raise (ArgumentError.new "Invalid indicator: #{indicator_id}")
    end
    unless level.value.between?(2, 5)
      raise RangeError.new 'level is not between 2 and 5'
    end
    return(
      @fixture['benchmarks'][capacity_id]['indicators'][indicator_id][
        'activities'
      ][
        level.value.to_s
      ]
    )
  end

  def activity_texts(id)
    id_ = id.class == String ? (BenchmarkId.from_s id) : id
    capacity_id = String(id_.capacity)
    indicator_id = String(id_.indicator)
    @fixture.dig(
      'benchmarks',
      capacity_id,
      'indicators',
      indicator_id,
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
