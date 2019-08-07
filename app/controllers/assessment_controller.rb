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
  end

  def post
    @country = params.fetch(:country)
    @assessment_type = params.fetch(:assessment)

    @params = params
    @params.delete(:country)
    @params.delete(:assessment_type)
    @params.delete(:authenticity_token)
    @params.delete(:utf8)
    @params.delete(:controller)
    @params.delete(:action)
  end
end
