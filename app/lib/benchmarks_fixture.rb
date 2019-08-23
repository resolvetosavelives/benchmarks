class BenchmarksFixture
  attr_reader :fixture
  def initialize
    @fixture = JSON.load File.open './app/fixtures/benchmarks.json'
  end

  def capacities
    @fixture.keys.map(&:to_i).sort.map do |k|
      ({ id: k.to_s, name: @fixture[k.to_s]['name'] })
    end
  end

  def capacity_text(capacity_id)
    unless @fixture[capacity_id]
      raise (ArgumentError.new "Invalid capacity: #{capacity_id}")
    end
    @fixture[capacity_id]['name']
  end

  def indicator_text(id)
    capacity_id, indicator_id = id.split('.')
    unless @fixture[capacity_id]
      raise (ArgumentError.new "Invalid capacity: #{capacity_id}")
    end
    unless @fixture[capacity_id]['indicators'][indicator_id]
      raise (ArgumentError.new "Invalid indicator: #{indicator_id}")
    end
    @fixture[capacity_id]['indicators'][indicator_id]['indicator']
  end

  def objective_text(id)
    capacity_id, indicator_id = id.split('.')
    unless @fixture[capacity_id]
      raise (ArgumentError.new "Invalid capacity: #{capacity_id}")
    end
    unless @fixture[capacity_id]['indicators'][indicator_id]
      raise (ArgumentError.new "Invalid indicator: #{indicator_id}")
    end
    @fixture[capacity_id]['indicators'][indicator_id]['objective']
  end

  def goal_activities(id, score, goal)
    capacity_id, indicator_id = id.split('.')
    unless @fixture[capacity_id]
      raise (ArgumentError.new "Invalid capacity: #{capacity_id}")
    end
    unless @fixture[capacity_id]['indicators'][indicator_id]
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
        acc.concat @fixture[capacity_id]['indicators'][indicator_id][
                     'activities'
                   ][
                     level.to_s
                   ]
        acc
      end
    )
  end

  def level_activities(id, level)
    capacity_id, indicator_id = id.split('.')
    unless @fixture[capacity_id]
      raise (ArgumentError.new "Invalid capacity: #{capacity_id}")
    end
    unless @fixture[capacity_id]['indicators'][indicator_id]
      raise (ArgumentError.new "Invalid indicator: #{indicator_id}")
    end
    unless level.value.between?(2, 5)
      raise RangeError.new 'level is not between 2 and 5'
    end
    return(
      @fixture[capacity_id]['indicators'][indicator_id]['activities'][
        level.value.to_s
      ]
    )
  end

  def activity_texts(id)
    capacity_id, indicator_id = id.split('.')
    @fixture.dig(capacity_id, 'indicators', indicator_id, 'activities').values.flatten.map { |a| a['text'] }.uniq
  end

  def capacity_names
    @fixture.map { |k, v| v['name'] }
  end
end
