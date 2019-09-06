# Pair together a score and a goal.
class ScoreGoal
  attr_accessor :score, :goal

  def initialize(params)
    @score = params.fetch(:score)
    @goal = params.fetch(:goal)
  end

  def ==(rside)
    @score == rside.score && @goal == rside.goal
  end

  def merge(rside)
    ScoreGoal.new(
      score: [@score, rside.score].min, goal: [@goal, rside.goal].max
    )
  end
end
