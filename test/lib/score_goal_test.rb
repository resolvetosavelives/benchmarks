require 'test_helper'

class ScoreGoalTest < ActiveSupport::TestCase
  test 'merge two ScoreGoals that overlap' do
    res =
      ScoreGoal.new(score: (Score.new 1), goal: (Score.new 3)).merge(
        ScoreGoal.new(score: (Score.new 2), goal: (Score.new 4))
      )
    assert_equal res, ScoreGoal.new(score: (Score.new 1), goal: (Score.new 4))
  end

  test 'merge two ScoreGoals with no overlap' do
    res =
      ScoreGoal.new(score: (Score.new 1), goal: (Score.new 3)).merge(
        ScoreGoal.new(score: (Score.new 3), goal: (Score.new 4))
      )
    assert_equal res, ScoreGoal.new(score: (Score.new 1), goal: (Score.new 4))
  end

  test 'merge two ScoreGoals with a gap' do
    res =
      ScoreGoal.new(score: (Score.new 1), goal: (Score.new 2)).merge(
        ScoreGoal.new(score: (Score.new 3), goal: (Score.new 4))
      )
    assert_equal res, ScoreGoal.new(score: (Score.new 1), goal: (Score.new 4))
  end

  test 'merge two gapped ScoreGoals even in reverse order' do
    res =
      ScoreGoal.new(score: (Score.new 3), goal: (Score.new 4)).merge(
        ScoreGoal.new(score: (Score.new 1), goal: (Score.new 2))
      )
    assert_equal res, ScoreGoal.new(score: (Score.new 1), goal: (Score.new 4))
  end
end
