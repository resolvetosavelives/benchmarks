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
    capacity_ids = params[:capacity_ids]

    assessment =
      Assessment.find_by(country: @country, assessment_type: assessment_type)

    @data_dictionary = JSON.load File.open './app/fixtures/data_dictionary.json'
    @assessments = JSON.load File.open './app/fixtures/assessments.json'
    @countries, @selectables = helpers.set_country_selection_options(false)

    if assessment
      @goals =
        GoalForm.new country: @country,
                     assessment_type: assessment_type,
                     scores: scores_from_assessment(assessment, assessment_type)

      @technical_area_ids =
        @assessments[@goals.assessment_type]['technical_area_order']
      @technical_areas = technical_areas(@technical_area_ids, @data_dictionary)
      @label = @assessments[assessment_type]['label']
      @display_assessment_type = assessment_type
    elsif capacity_ids
      @technical_area_ids = capacity_ids
      @goals =
        GoalForm.new country: @country,
                     assessment_type: assessment_type,
                     scores:
                       scores_from_technical_area_ids(
                         @technical_area_ids,
                         @assessments
                       )
      @label = 'Capacity Area'
      @display_assessment_type = 'spar_2018'
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

  private

  def scores_from_assessment(assessment, assessment_type)
    assessment.scores.reduce({}) do |scores, score|
      key = "#{assessment_type}_ind_#{score['indicator_id']}"
      scores[key] = Score.new score['score']
      scores
    end
  end

  def scores_from_technical_area_ids(technical_area_ids, assessments)
    indicator_ids =
      technical_area_ids.flat_map do |technical_area_id|
        assessments['spar_2018']['technical_areas'][technical_area_id][
          'indicators'
        ]
      end
    indicator_ids.reduce({}) do |scores, indicator_id|
      scores[indicator_id] = Score.new(1)
      scores
    end
  end

  def technical_areas(ids, data_dictionary)
    ids.map { |indicator_id| [data_dictionary[indicator_id], indicator_id] }
  end
end
