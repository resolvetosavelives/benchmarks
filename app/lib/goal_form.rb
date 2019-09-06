def create_goal(score)
  Score.new ([[score.value + 1, 5].min, 2].max)
end

# A GoalForm object that corresponds to the form in the visible goals page
#
# Accessors get created for every assessment indicator score and for the
# assessment indicator goal and should correspond to the form in the HTML page.
# The accessors are the form of `<assessment_type>_ind_<indicator>` and
# `<assessment_type>_ind_<indicator>=. This effectively looks like
# `spar_2018_ind_c92` and `spar_2018_ind_c92=`.
class GoalForm
  include ActiveModel::Model
  attr_accessor :country, :assessment_type

  def initialize(args)
    @country = args.fetch(:country)
    @assessment_type = args.fetch(:assessment_type)

    puts "GoalForm scores: #{args.fetch(:scores)}"

    scores = args.fetch(:scores)
    self.class.attr_accessor(*(scores.keys))
    self.class.attr_accessor(*(scores.keys.map { |k| "#{k}_goal" }))

    scores.each { |key, score| send "#{key}=", score.value }
    scores.each { |key, score| send "#{key}_goal=", create_goal(score).value }
  end

  # Create a draft plan from the form parameters
  def self.create_draft_plan!(params, crosswalk, benchmarks, current_user = nil)
    score_goals =
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
      score_goals.each.reduce({}) do |acc, (key, pairing)|
        benchmark_id = BenchmarkId.from_s(key)
        pairing.score = Score.new 1 if pairing.score.value == 0
        acc[key] =
          benchmarks.goal_activities benchmark_id, pairing.score, pairing.goal
        acc
      end

    goals =
      score_goals.each.reduce({}) do |acc, (key, pairing)|
        acc[key] = pairing.goal
        acc
      end

    scores =
      score_goals.each.reduce({}) do |acc, (key, pairing)|
        acc[key] = pairing.score
        acc
      end


    Plan.create! name: "#{params.fetch(:country)} draft plan",
                 country: params.fetch(:country),
                 assessment_type: params.fetch(:assessment_type),
                 activity_map: benchmark_activities,
                 user_id: current_user && current_user.id,
                 goals: goals,
                 scores: scores
  end
end
