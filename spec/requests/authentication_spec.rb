require "rails_helper"

# Describe authentication using the plans index which always requires authentication.
RSpec.describe "Authentication", type: :request do
  include Devise::Test::IntegrationHelpers

  context "not logged in" do
    it "redirects to new session path" do
      get plans_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context "logged in via database" do
    let(:user) { create :user }
    before { sign_in user }

    it "renders" do
      get plans_path
      expect(response).to have_http_status(:success)
    end
  end

  context "with azure authentication" do
    let(:sub) { "1234567890" }
    let(:claims) { { sub: sub, iat: 1.minute.ago.to_i } }
    let(:jwt) { JWT.encode(claims, "hmac_secret", "HS256") }

    before { Rails.application.config.azure_auth_enabled = true }
    after { Rails.application.config.azure_auth_enabled = false }

    context "with new user" do
      it "creates a new user and renders" do
        count = User.count
        headers = { "X-MS-TOKEN-AAD-ID-TOKEN" => jwt }

        get plans_path, headers: headers

        expect(response).to have_http_status(:success)
        expect(User.count).to eq(count + 1)

        user = User.last
        expect(user.azure_identity).to eq(sub)
      end
    end

    context "with existing user" do
      let!(:user) { create :user, azure_identity: sub }

      it "renders" do
        count = User.count
        headers = { "X-MS-TOKEN-AAD-ID-TOKEN" => jwt }

        get plans_path, headers: headers

        expect(response).to have_http_status(:success)
        expect(User.count).to eq(count)
      end
    end
  end
end
