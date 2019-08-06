class AssessmentController < ApplicationController
  def show
    @country = params[:country]
    @assessment = params[:assessment]

    file = File.open 'app/fixtures/assessments.json'
    @assessments = JSON.load file
  end
end
