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

  def self.create_draft_plan!(params, crosswalk, benchmarks_and_activities)
    result =
      params.keys.reduce({}) do |benchmark_acc, key|
        unless key.start_with?('jee1_') || key.start_with?('jee2_') ||
               key.start_with?('spar_')
          next benchmark_acc
        end
        next benchmark_acc if key.end_with?('_goal')
        score = params[key].to_i
        goal = params["#{key}_goal"].to_i

        raise "key #{key} not found in crosswalk" unless crosswalk[key]

        benchmark_ids = crosswalk[key]
        benchmark_ids.each do |id|
          activities =
            (score + 1..goal).reduce([]) do |activity_acc, level|
              activities = benchmarks_and_activities[id]['capacity'][level.to_s]
              activity_acc.concat(activities)
              activity_acc
            end
          benchmark_acc[id] = [] unless benchmark_acc[id]
          benchmark_acc[id].concat(activities)
        end
        benchmark_acc
      end

    Plan.create! name: "#{params.fetch(:country)} draft plan",
                 country: params.fetch(:country),
                 assessment_type: params.fetch(:assessment_type),
                 activity_map: result
  end
end
