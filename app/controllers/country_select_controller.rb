# This controller responds to the various dialogues that we use in which the
# user has selected a country and an assessment. It really only processes the
# parameters and then redirects to the goals controller so that the URL
# reflects the goals sheet directly.
class CountrySelectController < ApplicationController
  def create
    country_name = params.fetch(:country)
    assessment_type = params.fetch(:assessment_type)
    capacity_ids = params[:capacity_ids]

    redirect_to(
      {
        controller: 'goals',
        action: 'show',
        country: country_name,
        assessment_type: assessment_type,
        capacity_ids: capacity_ids
      }
    )
  end
end
