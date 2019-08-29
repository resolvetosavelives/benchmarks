class GoalsController < ApplicationController
  def show
    @country = params[:country]
    assessment_type = params[:assessment_type]

    assessment =
      Assessment.find_by(country: @country, assessment_type: assessment_type)

    if assessment
      scores = assessment.scores

      scores =
        scores.reduce({}) do |acc, score|
          key = "#{assessment_type}_ind_#{score['indicator_id']}"
          acc[key] = Score.new score['score']
          acc
        end

      @data_dictionary =
        JSON.load File.open './app/fixtures/data_dictionary.json'
      @assessments = JSON.load File.open './app/fixtures/assessments.json'

      @goals =
        GoalForm.new country: @country,
                     assessment_type: assessment_type,
                     scores: scores

      @countries, @selectables = helpers.set_country_selection_options
      @technical_areas = @assessments[@goals.assessment_type]["technical_area_order"].map do |indicator_id|
        [@data_dictionary[indicator_id], indicator_id]
      end
    end
  end

  def create
    crosswalk = JSON.load File.open './app/fixtures/crosswalk.json'
    benchmarks = BenchmarksFixture.new

    goal_params = params.fetch(:goal_form)

    plan = GoalForm.create_draft_plan! goal_params,
                                       crosswalk,
                                       benchmarks,
                                       current_user
    session[:plan_id] = plan.id unless current_user
    redirect_to plan
  end
end
