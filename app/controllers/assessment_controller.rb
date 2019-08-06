class AssessmentController < ApplicationController
  def show
    @country = params[:country]
    @assessment = params[:assessment]

    @data_dictionary = JSON.load File.open './app/fixtures/data_dictionary.json'
    @assessments = JSON.load File.open './app/fixtures/assessments.json'
  end
end
