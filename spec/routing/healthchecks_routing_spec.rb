require "rails_helper"

RSpec.describe "routes for Healthchecks", type: :routing do
  it "routes /healthcheck to healthchecks#index" do
    expect(get("/healthcheck")).to route_to("healthchecks#index")
  end
end
