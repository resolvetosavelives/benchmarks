require "rails_helper"

RSpec.describe "routing for Plans", type: :routing do
  it "routes GET /plans to plans#show" do
    expect(get("/plans")).to route_to("plans#index")
  end

  it "routes POST /plans to plans#show" do
    expect(post("/plans")).to route_to("plans#create")
  end

  it "routes GET /plans/id to plans#show" do
    expect(get("/plans/1")).to route_to("plans#show", id: "1")
  end

  it "routes PATCH /plans/id to plans#update" do
    expect(patch("/plans/1")).to route_to("plans#update", id: "1")
  end

  it "routes DELETE /plans/id to plans#destroy" do
    expect(delete("/plans/1")).to route_to("plans#destroy", id: "1")
  end
end
