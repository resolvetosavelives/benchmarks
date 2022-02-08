require "rails_helper"

RSpec.describe "Azure::MockSessions", type: :request do
  let(:cookie) { Azure::MockSessionsController::COOKIE }

  before { Rails.application.config.azure_auth_mocked = true }
  after { Rails.application.config.azure_auth_mocked = false }

  describe "GET /.auth/login/aad" do
    it "renders the mock azure login" do
      get "/.auth/login/aad"
      expect(response.body).to include("Fake Azure Auth")
    end

    it "renders the login form with the redirect link" do
      redirect_path = "/plans"
      get "/.auth/login/aad?post_login_redirect_uri=#{redirect_path}"
      expect(response.body).to include("value=\"#{redirect_path}\"")
    end
  end

  describe "POST /.auth/login/aad" do
    it "creates the authentication cookie" do
      post "/.auth/login/aad", params: { email: "martin@cloudcity.io" }
      expect(response.cookies[cookie]).to be_present
      expect(response).to redirect_to("/")
    end

    it "redirects as requested" do
      redirect_path = "/plans"
      post "/.auth/login/aad",
           params: {
             email: "martin@cloudcity.io",
             post_login_redirect_uri: redirect_path
           }
      expect(response.cookies[cookie]).to be_present
      expect(response).to redirect_to(redirect_path)
    end
  end

  describe "GET /.auth/logout" do
    before do
      post "/.auth/login/aad"
      expect(response.cookies[cookie]).to be_present
    end

    it "destroys the cookie" do
      get "/.auth/logout"
      expect(response.cookies[cookie]).to be_nil
      expect(response).to redirect_to("/")

      follow_redirect!

      # ensure the cookie isn't reissued because devise held onto a session.
      expect(response.cookies[cookie]).to be_nil
    end

    it "redirects as requested" do
      redirect_path = "/get-started"
      get "/.auth/logout?post_logout_redirect_uri=#{redirect_path}"
      expect(response.cookies[cookie]).to be_nil
      expect(response).to redirect_to(redirect_path)
    end
  end
end
