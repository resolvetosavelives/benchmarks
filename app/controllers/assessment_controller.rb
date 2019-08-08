class AssessmentController < ApplicationController
  def show
    @country = params[:country]
    @assessment_type = params[:assessment]

    @assessment =
      Assessment.find_by(country: @country, assessment_type: @assessment_type)

    scores = @assessment.scores if @assessment

    @scores =
      scores.reduce({}) do |acc, score|
        key = "#{@assessment_type}_ind_#{score['indicator_id']}"
        acc[key] = score['score']
        acc
      end

    @data_dictionary = JSON.load File.open './app/fixtures/data_dictionary.json'
    @assessments = JSON.load File.open './app/fixtures/assessments.json'

    @goals =
      GoalForm.new country: @country,
                   assessment_type: @assessment_type,
                   scores: @scores
  end

  def post
    crosswalk = JSON.load File.open './app/fixtures/crosswalk.json'
    benchmarks_and_activities =
      JSON.load File.open './app/fixtures/benchmarks_and_activities.json'

    @country = params.fetch(:country)
    @assessment_type = params.fetch(:assessment)

    @params = params
    params.delete(:country)
    params.delete(:assessment_type)
    params.delete(:authenticity_token)
    params.delete(:utf8)
    params.delete(:controller)
    params.delete(:action)
    params.delete(:assessment)

    # jee1_ind_p11
    # jee1_ind_p11_goal

    @result =
      params.keys.reduce([]) do |acc, key|
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
