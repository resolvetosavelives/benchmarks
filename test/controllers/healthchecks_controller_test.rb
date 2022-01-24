require "test_helper"

describe HealthchecksController do
  describe "#index" do
    it "is connected as /healthcheck" do
      assert_routing(
        "/healthcheck",
        { controller: "healthchecks", action: "index" }
      )
    end

    it "responds with success" do
      get healthcheck_url
      assert_response :success
    end
  end
end
