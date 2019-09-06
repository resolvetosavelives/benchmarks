require 'test_helper'

class BenchmarksFixtureTest < ActiveSupport::TestCase
  test 'reports activities for the requested level' do
    benchmarks = BenchmarksFixture.new

    activities =
      benchmarks.level_activities (BenchmarkId.from_s '1.1'), (Score.new 2)
    assert_equal activities.length, 6
    assert_equal activities[0]['text'],
                 'Identify and convene key stakeholders related to the review, formulation and implementation of legislation and policies.'
  end

  test 'calculates activities for a score/goal range' do
    benchmarks = BenchmarksFixture.new

    activities =
      benchmarks.goal_activities(
        (BenchmarkId.from_s '1.1'),
        (Score.new 2),
        (Score.new 4)
      )
    assert_equal activities.length, 8
    assert_equal activities[0]['text'],
                 'Conduct an orientation with relevant stakeholders regarding adjustment in the legislation, laws, regulations, policy and administrative requirements.'
    assert_equal activities[7]['text'],
                 'Document these legislation references and relevant interpretations that can assist in IHR implementation.'
  end

  test 'raises an exception if a parameter is out of range' do
    benchmarks = BenchmarksFixture.new
    assert_raises(RangeError) do
      benchmarks.level_activities (BenchmarkId.from_s '1.1'), (Score.new 0)
    end
    assert_raises(RangeError) do
      benchmarks.level_activities (BenchmarkId.from_s '1.1'), (Score.new 6)
    end
    assert_raises(RangeError) do
      benchmarks.goal_activities (BenchmarkId.from_s '1.1'),
                                 (Score.new 6),
                                 (Score.new 5)
    end
    assert_raises(RangeError) do
      benchmarks.goal_activities (BenchmarkId.from_s '1.1'),
                                 (Score.new 0),
                                 (Score.new 5)
    end
    assert_raises(RangeError) do
      benchmarks.goal_activities (BenchmarkId.from_s '1.1'),
                                 (Score.new 1),
                                 (Score.new 0)
    end
    assert_raises(RangeError) do
      benchmarks.goal_activities (BenchmarkId.from_s '1.1'),
                                 (Score.new 1),
                                 (Score.new 6)
    end
    assert_raises(ArgumentError) do
      benchmarks.goal_activities (BenchmarkId.from_s '1.1'),
                                 (Score.new 5),
                                 (Score.new 3)
    end
  end

  test 'returns the correct capacity text for a given id' do
    benchmarks = BenchmarksFixture.new
    assert_raises(ArgumentError) { benchmarks.capacity_text '19' }

    assert_equal 'Chemical Events', (benchmarks.capacity_text '17')
  end

  test 'returns the correct indicator text for a given id' do
    benchmarks = BenchmarksFixture.new
    assert_raises(ArgumentError) do
      benchmarks.indicator_text (BenchmarkId.from_s '19.1')
    end
    assert_raises(ArgumentError) do
      benchmarks.indicator_text (BenchmarkId.from_s '17.2')
    end
    assert_equal 'Mechanisms are in place for surveillance, alert and response to chemical events or emergencies',
                 (benchmarks.indicator_text (BenchmarkId.from_s '17.1'))
  end

  test 'returns the correct objective text for a given id' do
    benchmarks = BenchmarksFixture.new
    assert_raises(ArgumentError) do
      benchmarks.objective_text (BenchmarkId.from_s '19.1')
    end
    assert_raises(ArgumentError) do
      benchmarks.objective_text (BenchmarkId.from_s '17.2')
    end
    assert_equal 'Establish policies, legislation, plans and capacities for surveillance, alert and response to chemical events or emergencies',
                 (benchmarks.objective_text (BenchmarkId.from_s '17.1'))
  end

  test 'returns the text of a type code' do
    benchmarks = BenchmarksFixture.new
    assert_raises(ArgumentError) { benchmarks.type_code_text '4', '1' }
    assert_raises(ArgumentError) { benchmarks.type_code_text '1', '100' }
    assert_equal 'SimEx and AAR', (benchmarks.type_code_text '1', '11')
  end
end
