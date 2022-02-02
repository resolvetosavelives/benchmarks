require "rails_helper"

RSpec.describe "routing for Start", type: :routing do
  it "routes GET /get-started to start#index" do
    expect(get("/get-started")).to route_to("start#index")
  end

  it "routes POST /get-started to start#create" do
    expect(post("/get-started")).to route_to("start#create")
  end

  it "routes GET /get-started/1 to start#index" do
    expect(get("/get-started/1")).to route_to("start#show", id: "1")
  end

  it "routes PATCH /get-started/1 to start#index" do
    expect(patch("/get-started/1")).to route_to("start#update", id: "1")
  end
end
