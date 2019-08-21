class BenchmarksFixture
  def initialize
    @fixture = JSON.load File.open './app/fixtures/benchmarks.json'
  end

  def capacity_text(capacity_id)
    @fixture[capacity_id]['name']
  end

  def indicator_text(id)
    capacity_id, indicator_id = id.split('.')
    @fixture[capacity_id]['indicators'][indicator_id]['benchmark']
  end

  def objective_text(id)
    capacity_id, indicator_id = id.split('.')
    @fixture[capacity_id]['indicators'][indicator_id]['objective']
  end

  def goal_activities(id, score, goal)
    capacity_id, indicator_id = id.split('.')
    unless @fixture[capacity_id]['indicators'][indicator_id]
      raise ArgumentError.new "invalid benchmark: #{capacity_id} #{
                                indicator_id
                              }"
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
    unless level.value.between?(2, 5)
      raise RangeError.new 'level is not between 2 and 5'
    end
    return(
      @fixture[capacity_id]['indicators'][indicator_id]['activities'][
        level.value.to_s
      ]
    )
  end
end
