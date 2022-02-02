require "rails_helper"

RSpec.describe "Worksheets", type: :request do
  include Devise::Test::IntegrationHelpers

  describe "GET /worksheets/:id" do
    let(:plan) { create(:plan, :with_user) }
    let(:non_extant_plan_id) { 987_654_321 }

    it "redirects logged out user" do
      get worksheet_path(non_extant_plan_id)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "redirects a user who does not have access to the specified plan" do
      sign_in create(:user)
      get worksheet_path(plan.id)
      expect(response).to redirect_to(plans_path)
    end

    it "redirects a logged in user if a plan does not exist" do
      sign_in plan.user
      get worksheet_path(non_extant_plan_id)

      expect(response).to redirect_to(plans_path)
    end

    it "provides an excel sheet if the plan exists" do
      worksheet = instance_double(Worksheet, to_s: "")
      expect(Worksheet).to receive(:new).and_return(worksheet)

      sign_in plan.user

      get worksheet_path(plan.id)
      expect(response).to have_http_status(:success)
    end
  end
end
