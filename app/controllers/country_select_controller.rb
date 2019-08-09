class CountrySelectController < ApplicationController
  def create
    @country_name = params.fetch(:country)

    assessments = Assessments.find_by(country: @country_name)

    @available_assessments = assessments.map &:assessment_type
  end
end
