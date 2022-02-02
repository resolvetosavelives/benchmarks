require "rails_helper"

RSpec.describe "Pages", type: :request do
  describe "GET /" do
    it "responds with success" do
      get root_url
      expect(response).to have_http_status(:success)
    end
  end

  routes =
    Rails.application.routes.routes.map do |r|
      r.path.spec.to_s.sub("(.:format)", "")
    end

  static_routes = routes.grep(%r{^\/(privacy|reference-library|document\/)})
  static_routes.each do |path|
    describe "path #{path}" do
      it "renders successfully" do
        get path
        expect(response).to have_http_status(:success)
      end
    end
  end
end
