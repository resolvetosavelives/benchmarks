require 'test_helper'

class BenchmarksFixtureTest < ActiveSupport::TestCase
  test 'reports activities for the requested level' do
    benchmarks = BenchmarksFixture.new

    activities = benchmarks.activities('1.1', level: 2)
    assert_equal activities.length, 6
    assert_equal activities[0],
                 'Identify and convene key stakeholders related to the review, formulation and implementation of legislation and policies.'
  end

  test 'calculates activities for a score/goal range' do
    benchmarks = BenchmarksFixture.new

    activities = benchmarks.activities('1.1', score: 2, goal: 4)
    assert_equal activities.length, 8
    assert_equal activities[0],
                 'Conduct an orientation with relevant stakeholders regarding adjustment in the legislation, laws, regulations, policy and administrative requirements.'
    assert_equal activities[7],
                 'Document these legislation references and relevant interpretations that can assist in IHR implementation.'
  end

  test 'raises an exception if a parameter is out of range' do
    benchmarks = BenchmarksFixture.new
    assert_raises(OutOfBounds) { || benchmarks.activities '1.1', level: 0 }
    assert_raises(OutOfBounds) { || benchmarks.activities '1.1', level: 6 }
    assert_raises(InvalidParameter) { || benchmarks.activities '1.1', goal: 0 }
    assert_raises(InvalidParameter) { || benchmarks.activities '1.1', score: 0 }
    assert_raises(OutOfBounds) do ||
      benchmarks.activities '1.1', score: 6, goal: 5
    end
    assert_raises(OutOfBounds) do ||
      benchmarks.activities '1.1', score: 0, goal: 5
    end
    assert_raises(OutOfBounds) do ||
      benchmarks.activities '1.1', score: 1, goal: 0
    end
    assert_raises(OutOfBounds) do ||
      benchmarks.activities '1.1', score: 1, goal: 6
    end
    assert_raises(InvalidParameter) do ||
      benchmarks.activities '1.1', score: 5, goal: 3
    end
  end
end
