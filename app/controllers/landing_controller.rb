# Displays the landing page when the user arrives at the "/" URL. The only
# thing interesting this does is to populate the options for the country and
# assessment dropdown menus.
class LandingController < ApplicationController
  def show
    @countries, @selectables = helpers.set_country_selection_options(true)
    @assessments = JSON.load File.open './app/fixtures/assessments.json'
    @data_dictionary = JSON.load File.open './app/fixtures/data_dictionary.json'
  end
end
