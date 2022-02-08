require "rails_helper"

RSpec.describe "routing for Azure::Sessions", type: :routing do
  context "with routes constrained" do
    before { expect(Rails.application.config.azure_auth_mocked).to be_falsy }

    it "allows the named route azure_login_path" do
      expect(azure_login_path).to eq("/.auth/login/aad")
    end

    it "allows the named route azure_logout_path" do
      expect(azure_logout_path).to eq("/.auth/logout")
    end

    it "refuses to route GET /.auth/login/aad" do
      expect(get("/.auth/login/aad")).not_to be_routable
    end

    it "refuses to route POST /.auth/login/aad" do
      expect(post("/.auth/login/aad")).not_to be_routable
    end

    it "refuses to route GET /.auth/logout" do
      expect(get("/.auth/logout")).not_to be_routable
    end
  end

  context "with routes enabled" do
    before { Rails.application.config.azure_auth_mocked = true }
    after { Rails.application.config.azure_auth_mocked = false }

    it "allows the named route azure_login_path" do
      expect(azure_login_path).to eq("/.auth/login/aad")
    end

    it "allows the named route azure_logout_path" do
      expect(azure_logout_path).to eq("/.auth/logout")
    end

    it "routes GET /.auth/login/aad to azure/mock_sessions#new" do
      expect(get("/.auth/login/aad")).to route_to("azure/mock_sessions#new")
    end

    it "routes POST /.auth/login/aad to azure/mock_sessions#create" do
      expect(post("/.auth/login/aad")).to route_to("azure/mock_sessions#create")
    end

    it "routes GET /.auth/logout to azure/mock_sessions#destroy" do
      expect(get("/.auth/logout")).to route_to("azure/mock_sessions#destroy")
    end
  end
end
