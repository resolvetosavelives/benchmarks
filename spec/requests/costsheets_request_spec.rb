require "rails_helper"

RSpec.describe "Costsheets", type: :request do
  include Devise::Test::IntegrationHelpers

  describe "GET /costsheets/:id" do
    let(:plan) { create(:plan, :with_user) }
    let(:non_extant_plan_id) { 987_654_321 }

    it "redirects logged out user" do
      get costsheet_path(non_extant_plan_id)

      expect(response).to redirect_to(new_user_session_path)
    end

    it "redirects a user who does not have access to the specified plan" do
      sign_in create(:user)
      get costsheet_path(plan.id)

      expect(response).to redirect_to(plans_path)
    end

    it "redirects a logged in user if a plan does not exist" do
      sign_in create(:user)
      get costsheet_path(non_extant_plan_id)

      expect(response).to redirect_to(plans_path)
    end

    it "provides an excel sheet if the plan exists" do
      costsheet = instance_double(CostSheet, to_s: "")
      allow(CostSheet).to receive(:new).and_return(costsheet)

      sign_in plan.user

      get costsheet_path(plan.id)

      expect(response).to have_http_status(:success)
    end
  end
end
