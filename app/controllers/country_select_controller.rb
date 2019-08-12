class CountrySelectController < ApplicationController
  def create
    country_name = params.fetch(:country)
    assessment_type = params.fetch(:assessment_type)

    redirect_to(
      {
        controller: 'goals',
        action: 'show',
        country: country_name,
        assessment_type: assessment_type
      }
    )
  end
end
