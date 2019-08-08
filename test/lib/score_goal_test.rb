require 'test_helper'

class ScoreGoalTest < ActiveSupport::TestCase
  test 'merge two ScoreGoals that overlap' do
    res =
      ScoreGoal.new(score: 1, goal: 3).merge(ScoreGoal.new(score: 2, goal: 4))
    assert_equal res, ScoreGoal.new(score: 1, goal: 4)
  end

  test 'merge two ScoreGoals with no overlap' do
    res =
      ScoreGoal.new(score: 1, goal: 3).merge(ScoreGoal.new(score: 3, goal: 4))
    assert_equal res, ScoreGoal.new(score: 1, goal: 4)
  end

  test 'merge two ScoreGoals with a gap' do
    res =
      ScoreGoal.new(score: 1, goal: 2).merge(ScoreGoal.new(score: 3, goal: 4))
    assert_equal res, ScoreGoal.new(score: 1, goal: 4)
  end

  test 'merge two gapped ScoreGoals even in reverse order' do
    res =
      ScoreGoal.new(score: 3, goal: 4).merge(ScoreGoal.new(score: 1, goal: 2))
    assert_equal res, ScoreGoal.new(score: 1, goal: 4)
  end
end
