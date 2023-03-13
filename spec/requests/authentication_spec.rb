require "rails_helper"

# Describe authentication using the plans index which always requires authentication.
RSpec.describe "Authentication", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create :user }

  context "not logged in" do
    it "redirects to new session path" do
      get plans_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context "logged in via database" do
    before { sign_in user }

    it "renders" do
      get plans_path
      expect(response).to have_http_status(:success)
    end
  end
end
