class CountryName
  attr_reader :name
  def initialize(name)
    @name = name
  end
end

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

      if assessment_type == 'spar_2018'
        scale = SparScale
      else
        scale = JeeScale
      end

      @data_dictionary =
        JSON.load File.open './app/fixtures/data_dictionary.json'
      @assessments = JSON.load File.open './app/fixtures/assessments.json'

      @goals =
        GoalForm.new country: @country,
                     assessment_type: assessment_type,
                     scores: scores,
                     scale: scale

      assessments = Assessment.all
      @selectables =
        assessments.reduce({}) do |acc, a|
          acc[a[:country]] = [] unless acc[a[:country]]
          acc[a[:country]].push(a[:assessment_type])
          acc
        end

      @countries = @selectables.keys.sort.map { |c| CountryName.new(c) }

    end
  end

  def create
    crosswalk = JSON.load File.open './app/fixtures/crosswalk.json'
    benchmarks = BenchmarksFixture.new

    goal_params = params.fetch(:goal_form)
    assessment_type = goal_params.fetch(:assessment_type)
    if assessment_type == 'spar_2018'
      scale = SparScale
    else
      scale = JeeScale
    end

    redirect_to GoalForm.create_draft_plan! goal_params,
                                            crosswalk,
                                            benchmarks,
                                            scale
  end
end
