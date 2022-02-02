require "rails_helper"

RSpec.describe "routes for Pages", type: :routing do
  describe "#home" do
    it "routes / to pages#home" do
      expect(get("/")).to route_to("pages#home")
    end
  end
end
