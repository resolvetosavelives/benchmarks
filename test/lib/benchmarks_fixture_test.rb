require 'test_helper'

class BenchmarksFixtureTest < ActiveSupport::TestCase
  test 'reports activities for the requested level' do
    benchmarks = BenchmarksFixture.new

    activities = benchmarks.level_activities '1.1', (Score.new 2)
    assert_equal activities.length, 6
    assert_equal activities[0]['text'],
                 'Identify and convene key stakeholders related to the review, formulation and implementation of legislation and policies.'
  end

  test 'calculates activities for a score/goal range' do
    benchmarks = BenchmarksFixture.new

    activities = benchmarks.goal_activities('1.1', (Score.new 2), (Score.new 4))
    assert_equal activities.length, 8
    assert_equal activities[0]['text'],
                 'Conduct an orientation with relevant stakeholders regarding adjustment in the legislation, laws, regulations, policy and administrative requirements.'
    assert_equal activities[7]['text'],
                 'Document these legislation references and relevant interpretations that can assist in IHR implementation.'
  end

  test 'raises an exception if a parameter is out of range' do
    benchmarks = BenchmarksFixture.new
    assert_raises(RangeError) do
      benchmarks.level_activities '1.1', (Score.new 0)
    end
    assert_raises(RangeError) do
      benchmarks.level_activities '1.1', (Score.new 6)
    end
    assert_raises(RangeError) do
      benchmarks.goal_activities '1.1', (Score.new 6), (Score.new 5)
    end
    assert_raises(RangeError) do
      benchmarks.goal_activities '1.1', (Score.new 0), (Score.new 5)
    end
    assert_raises(RangeError) do
      benchmarks.goal_activities '1.1', (Score.new 1), (Score.new 0)
    end
    assert_raises(RangeError) do
      benchmarks.goal_activities '1.1', (Score.new 1), (Score.new 6)
    end
    assert_raises(ArgumentError) do
      benchmarks.goal_activities '1.1', (Score.new 5), (Score.new 3)
    end
  end

  test 'returns the correct capacity text for a given id' do
    assert false
  end

  test 'returns the correct indicator text for a given id' do
    assert false
  end

  test 'returns the correct objective text for a given id' do
    assert false
  end
end
