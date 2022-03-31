require "rails_helper"

# Describe authentication using the plans index which always requires authentication.
RSpec.describe "Authentication", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:sub) { "1234567890" }
  let(:claims) { { sub: sub, iat: 1.minute.ago.to_i } }
  let(:jwt) { JWT.encode(claims, "hmac_secret", "HS256") }
  let(:user) { create :user }
  let(:headers) { { Azure::AuthStrategy::ID_TOKEN_HEADER_HTTP => jwt } }

  context "not logged in" do
    it "redirects to new session path" do
      get plans_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "ignores JWT header when azure auth is not enabled" do
      get plans_path, headers: headers
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

  context "with azure authentication" do
    before { Rails.application.config.azure_auth_enabled = true }
    after { Rails.application.config.azure_auth_enabled = false }

    context "without auth" do
      it "redirects to new user session path" do
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

    context "with auth headers" do
      it "creates a new user from auth header" do
        count = User.count

        get plans_path, headers: headers

        expect(response).to have_http_status(:success)
        expect(User.count).to eq(count + 1)

        user = User.last
        expect(user.azure_identity).to eq(sub)
      end

      it "loads the existing user from auth header" do
        user.update!(azure_identity: sub)
        count = User.count

        get plans_path, headers: headers

        expect(response).to have_http_status(:success)
        expect(User.count).to eq(count)
      end
    end
  end
end
