require(File.expand_path("./test/test_helper"))
class PlansControllerTest < ActionDispatch::IntegrationTest
  include(Devise::Test::IntegrationHelpers)
  describe(StartController) do
    describe("#index") do
      it("is connected as /get-started") do
        assert_routing("/get-started", controller: "start", action: "index")
      end
      it("responds with success") do
        get(get_started_url)
        assert_response(:success)
        assert_template(:index)
      end
    end
    describe("#create") do
      it("redirects to the country") do
        country_id = 4
        post(
          start_index_url,
          params: ({ get_started_form: ({ country_id: country_id }) })
        )
        assert_redirected_to(start_url(id: country_id))
      end
    end
    describe("#show") do
      it("shows the form") do
        get(start_url(id: 4))
        assert_response(:success)
        assert_template(:show)
      end
    end
    describe("#update") do
      it("redirects to plan goals") do
        put(
          start_url(id: 4),
          params:
            (
              {
                get_started_form:
                  ({ assessment_type: "jee1", plan_term: "1-year" })
              }
            )
        )
        assert_redirected_to(
          plan_goals_url(
            country_name: "Algeria",
            assessment_type: "jee1",
            plan_term: "1-year"
          )
        )
      end
    end
  end
end
