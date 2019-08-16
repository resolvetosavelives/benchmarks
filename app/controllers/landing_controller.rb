class LandingController < ApplicationController
  def show
    @countries, @selectables = helpers.set_country_selection_options
  end
end
