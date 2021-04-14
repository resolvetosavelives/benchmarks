require("rails_helper")
describe(PagesController) do
  describe("#home") do
    it("is connected as the root URL") do
      assert_routing("/", controller: "pages", action: "home")
    end
    it("responds with success") do
      get(root_url)
      assert_response(:success)
    end
  end
  routes =
    Rails
      .application
      .routes
      .routes
      .map { |r| r.path.spec.to_s.sub("(.:format)", "") }
  static_routes = routes.grep(%r{^\/(privacy|reference-library|document\/)})
  static_routes.each do |path|
    describe("path #{path}") do
      it("renders successfully") do
        get(path)
        assert_response(:success)
      end
    end
  end
end
