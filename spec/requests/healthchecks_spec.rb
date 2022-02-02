require "rails_helper"

RSpec.describe "Healthchecks", type: :request do
  describe "GET /healthchecks" do
    it "returns 200" do
      get healthcheck_path
      expect(response).to have_http_status(204)
    end
  end
end
