def create_goal(score)
  Score.new ([[score.value + 1, 5].min, 2].max)
end

class GoalForm
  include ActiveModel::Model
  attr_accessor :country, :assessment_type

  def initialize(args)
    @country = args.fetch(:country)
    @assessment_type = args.fetch(:assessment_type)

    scores = args.fetch(:scores)
    self.class.attr_accessor(*(scores.keys))
    self.class.attr_accessor(*(scores.keys.map { |k| "#{k}_goal" }))

    scores.each { |key, score| send "#{key}=", score.value }
    scores.each { |key, score| send "#{key}_goal=", create_goal(score).value }
  end

  def self.create_draft_plan!(params, crosswalk, benchmarks, current_user = nil)
    benchmark_goals =
      params.keys.reduce({}) do |benchmark_acc, key|
        unless key.start_with?('jee1_') || key.start_with?('jee2_') ||
               key.start_with?('spar_')
          next benchmark_acc
        end
        next benchmark_acc if key.end_with?('_goal')

        raise "key #{key} not found in crosswalk" unless crosswalk[key]
        next benchmark_acc if crosswalk[key] == %w[N/A]

        score_and_goal =
          ScoreGoal.new score: Score.new(params[key].to_i),
                        goal: Score.new(params["#{key}_goal"].to_i)

        benchmark_ids = crosswalk[key]
        benchmark_ids.each do |id|
          if benchmark_acc[id]
            benchmark_acc[id] = benchmark_acc[id].merge(score_and_goal)
          else
            benchmark_acc[id] = score_and_goal
          end
        end
        benchmark_acc
      end

    benchmark_activities =
      benchmark_goals.each.reduce({}) do |acc, (key, pairing)|
        benchmark_id = BenchmarkId.from_s(key)
        pairing.score = Score.new 1 if pairing.score.value == 0
        acc[key] =
          benchmarks.goal_activities benchmark_id, pairing.score, pairing.goal
        acc
      end

    goals =
      benchmark_goals.each.reduce({}) do |acc, (key, pairing)|
        acc[key] = pairing.goal
        acc
      end

    Plan.create! name: "#{params.fetch(:country)} draft plan",
                 country: params.fetch(:country),
                 assessment_type: params.fetch(:assessment_type),
                 activity_map: benchmark_activities,
                 user_id: current_user && current_user.id,
                 goals: goals
  end
end
