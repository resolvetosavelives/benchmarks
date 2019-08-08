class GoalForm
  include ActiveModel::Model
  attr_accessor :country, :assessment_type

  def initialize(args)
    @country = args.fetch(:country)
    @assessment_type = args.fetch(:assessment_type)

    scores = args.fetch(:scores)
    self.class.attr_accessor(*(scores.keys))
    self.class.attr_accessor(*(scores.keys.map { |k| "#{k}_goal" }))

    scores.each { |key, value| send "#{key}=", value }
    scores.each { |key, value| send "#{key}_goal=", [value + 1, 5].min }
  end

  def self.create_draft_plan!(params, crosswalk, benchmarks)
    benchmark_goals =
      params.keys.reduce({}) do |benchmark_acc, key|
        unless key.start_with?('jee1_') || key.start_with?('jee2_') ||
               key.start_with?('spar_')
          next benchmark_acc
        end
        next benchmark_acc if key.end_with?('_goal')

        score_goal =
          ScoreGoal.new score: params[key].to_i,
                        goal: params["#{key}_goal"].to_i

        raise "key #{key} not found in crosswalk" unless crosswalk[key]

        benchmark_ids = crosswalk[key]
        benchmark_ids.each do |id|
          if benchmark_acc[id]
            benchmark_acc[id] = benchmark_acc[id].merge(score_goal)
          else
            benchmark_acc[id] = score_goal
          end
        end
        benchmark_acc
      end

    benchmark_activities =
      benchmark_goals.each.reduce({}) do |acc, (key, value)|
        acc[key] =
          benchmarks.activities(key, score: value.score, goal: value.goal)
        acc
      end

    Plan.create! name: "#{params.fetch(:country)} draft plan",
                 country: params.fetch(:country),
                 assessment_type: params.fetch(:assessment_type),
                 activity_map: benchmark_activities
  end
end
