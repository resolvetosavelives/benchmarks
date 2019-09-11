# Handle the goals sheet.
#
# A GET (show) operation on the goals sheet will display the assessment, the
# scores for the assessment, and the initial goals.
#
# A POST (create) operation on the goals sheet will post the goals, but instead
# of creating an Assessment or a Goals model (there is no Goals model), with
# create a draft plan (the Plan model), and redirect to that newly created
# plan.
#
# This is a bit unusual for a REST app, but makes sense in this context where
# the assessments are all seeded into the database in advance, and goals are an
# ephemeral concept used to bridge the gap between an assessment and a plan,
# but not saved.
class GoalsController < ApplicationController
  def show
    @country = params[:country]
    assessment_type = params[:assessment_type]
    capacities = params[:capacities]

    assessment =
      Assessment.find_by(country: @country, assessment_type: assessment_type)

    @data_dictionary = JSON.load File.open './app/fixtures/data_dictionary.json'
    @assessments = JSON.load File.open './app/fixtures/assessments.json'

    if assessment
      scores =
        assessment.scores.reduce({}) do |acc, score|
          key = "#{assessment_type}_ind_#{score['indicator_id']}"
          acc[key] = Score.new score['score']
          acc
        end


      @goals =
        GoalForm.new country: @country,
                     assessment_type: assessment_type,
                     scores: scores

      @countries, @selectables = helpers.set_country_selection_options
      @technical_area_ids = @assessments[@goals.assessment_type]['technical_area_order']
      @technical_areas =
        @technical_area_ids
          .map { |indicator_id| [@data_dictionary[indicator_id], indicator_id] }
    elsif capacities
      @technical_area_ids = @data_dictionary.select { |k, v| v.in?(capacities) && k.match("spar") }.keys
      indicator_ids = @technical_area_ids.flat_map do |technical_area_id|
        @assessments["spar_2018"]["technical_areas"][technical_area_id]["indicators"]
      end
      scores = indicator_ids.reduce({}) do |acc, indicator_id|
        acc[indicator_id] = Score.new(1)
        acc
      end

      @goals = GoalForm.new country: @country, assessment_type: "spar_2018", scores: scores
      @countries, @selectables = helpers.set_country_selection_options
      @technical_areas =
        @assessments[@goals.assessment_type]['technical_area_order']
          .map { |indicator_id| [@data_dictionary[indicator_id], indicator_id] }
    end

  end

  def create
    crosswalk = JSON.load File.open './app/fixtures/crosswalk.json'
    benchmarks = BenchmarksFixture.new

    goal_params = params.fetch(:goal_form)

    plan =
      GoalForm.create_draft_plan! goal_params,
                                  crosswalk,
                                  benchmarks,
                                  current_user
    session[:plan_id] = plan.id unless current_user
    redirect_to plan
  end
end
