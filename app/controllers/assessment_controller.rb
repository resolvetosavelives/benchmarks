class AssessmentController < ApplicationController
  def show
    country = params[:country]
    assessment_type = params[:assessment]

    assessment =
      Assessment.find_by(country: country, assessment_type: assessment_type)

    @scores = assessment.scores if assessment
    @data_dictionary = JSON.load File.open './app/fixtures/data_dictionary.json'
    @assessments = JSON.load File.open './app/fixtures/assessments.json'
  end
end
