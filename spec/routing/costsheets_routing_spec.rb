require "rails_helper"

RSpec.describe "routing for Costsheets", type: :routing do
  it "routes GET /costsheets/1 to costsheets#show" do
    expect(get("/costsheets/1")).to route_to("costsheets#show", id: "1")
  end
end
