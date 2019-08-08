# class ContainerBase
#   def self.getset(*args)
#     args.each do |field|
#       getter(field)
#       setter(field)
#     end
#   end
#
#   def self.getter(*args)
#     args.each do |field|
#       define_method(field) { instance_variable_get("@#{field}") }
#     end
#   end
#
#   def self.setter(*args)
#     args.each do |field|
#       define_method("#{field}=") do |value|
#         instance_variable_set("@#{field}", value)
#       end
#     end
#   end
# end

class AssessmentController < ApplicationController
  def show
    @country = params[:country]
    @assessment_type = params[:assessment]

    @assessment =
      Assessment.find_by(country: @country, assessment_type: @assessment_type)

    if @assessment
      scores = @assessment.scores

      @scores =
        scores.reduce({}) do |acc, score|
          key = "#{@assessment_type}_ind_#{score['indicator_id']}"
          acc[key] = score['score']
          acc
        end

      @data_dictionary =
        JSON.load File.open './app/fixtures/data_dictionary.json'
      @assessments = JSON.load File.open './app/fixtures/assessments.json'

      @goals =
        GoalForm.new country: @country,
                     assessment_type: @assessment_type,
                     scores: @scores
    end
  end

  def post
    crosswalk = JSON.load File.open './app/fixtures/crosswalk.json'
    benchmarks_and_activities =
      JSON.load File.open './app/fixtures/benchmarks_and_activities.json'

    @country = params.fetch(:goal_form).fetch(:country)
    @assessment_type = params.fetch(:goal_form).fetch(:assessment_type)

    @params = params

    # jee1_ind_p11
    # jee1_ind_p11_goal

    @result =
      params.fetch(:goal_form).keys.reduce([]) do |acc, key|
        unless key.start_with?('jee1_') || key.start_with?('jee2_') ||
               key.start_with?('spar_')
          next acc
        end
        next acc if key.end_with?('_goal')
        score = params[key].to_i
        goal = params["#{key}_goal"].to_i

        puts "key #{key} not found in crosswalk" unless crosswalk[key]
        next acc unless crosswalk[key]
        benchmark_ids = crosswalk[key]
        benchmark_ids.each do |id|
          activities =
            (score + 1..goal).reduce([]) do |acc, level|
              activities = benchmarks_and_activities[id]['capacity'][level.to_s]
              acc.concat(activities)
              acc
            end
          acc.push({ benchmark_id: id, activities: activities })
        end
        acc
      end
  end
end
