require "rails_helper"

RSpec.describe "Start", type: :request do
  include Devise::Test::IntegrationHelpers

  describe "#index" do
    it "responds with success" do
      get get_started_url
      expect(response).to have_http_status(:success)
    end
  end

  describe "#create" do
    it "redirects to the country" do
      country_id = 4
      post start_index_url,
           params: {
             get_started_form: {
               country_id: country_id
             }
           }
      expect(response).to redirect_to(start_url(id: country_id))
    end
  end

  describe "#show" do
    it "shows the form" do
      get start_url(id: 4)
      expect(response).to have_http_status(:success)
    end
  end

  describe "#update" do
    it "redirects to plan goals" do
      put start_url(id: 4),
          params: {
            get_started_form: {
              assessment_type: "spar_2018",
              plan_term: "1-year"
            }
          }

      assert_redirected_to(
        plan_goals_url(
          country_name: "Algeria",
          assessment_type: "spar_2018",
          plan_term: "1-year"
        )
      )
    end
  end
end
