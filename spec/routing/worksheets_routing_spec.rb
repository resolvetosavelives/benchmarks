require "rails_helper"

RSpec.describe "routing for Worksheets", type: :routing do
  it "routes GET /worksheets/1 to worksheets#show" do
    expect(get("/worksheets/1")).to route_to("worksheets#show", id: "1")
  end
end
