require(File.expand_path("./test/test_helper"))
class PlansControllerTest < ActionDispatch::IntegrationTest
  include(Devise::Test::IntegrationHelpers)
  describe(PlansController) do
    describe("#goals") do
      describe("for a non-existent assessment") do
        it("responds with success") do
          get(
            plan_goals_url(
              country_name: "Xyz",
              assessment_type: "jee1",
              plan_term: "5-year"
            )
          )
          assert_response(:success)
        end
      end
      describe("for JEE1 5-year") do
        it("responds with success") do
          get(
            plan_goals_url(
              country_name: "Nigeria",
              assessment_type: "jee1",
              plan_term: "5-year"
            )
          )
          assert_response(:success)
        end
      end
      describe("for SPAR 2018 1-year") do
        it("responds with success") do
          get(
            plan_goals_url(
              country_name: "Nigeria",
              assessment_type: "spar_2018",
              plan_term: "1-year"
            )
          )
          assert_response(:success)
        end
      end
      describe("for JEE1 5-year plan by selected areas") do
        it("responds with success") do
          get(
            plan_goals_url(
              country_name: "Nigeria",
              assessment_type: "jee1",
              plan_term: "1-year",
              technical_area_ids: "2-4-9"
            )
          )
          assert_response(:success)
        end
      end
    end
    describe("#create") do
      describe("when the plan is saved") do
        before do
          plan.stubs(:persisted?).returns(true)
          plan.stubs(:id).returns(123)
        end
        let(:plan) { Plan.new }
        it("responds with success") do
          Plan.expects(:create_from_goal_form).with do |value|
            value[:is_5_year_plan].eql?(false)
          end.returns(plan)
          post(
            plans_url,
            params:
              (
                {
                  plan:
                    (
                      {
                        assessment_id: "123",
                        term: "100",
                        indicators: ({ abc: "123" }),
                        disease_ids: ""
                      }
                    )
                }
              )
          )
          assert_response(:redirect)
          assert_redirected_to(plan_path(plan.id))
        end
        describe("for a 5-year plan") do
          it("responds with success") do
            Plan.expects(:create_from_goal_form).with do |value|
              value[:is_5_year_plan].eql?(true)
            end.returns(plan)
            post(
              plans_url,
              params:
                (
                  {
                    plan:
                      (
                        {
                          assessment_id: "123",
                          term: "500",
                          indicators: ({ abc: "123" }),
                          disease_ids: "10"
                        }
                      )
                  }
                )
            )
            assert_response(:redirect)
            assert_redirected_to(plan_path(plan.id))
          end
        end
      end
      describe("when the plan is not saved") do
        it("responds with a redirect") do
          plan = Plan.new
          Plan.stub(:create_from_goal_form, plan) do
            post(
              plans_url,
              params:
                (
                  {
                    plan:
                      (
                        {
                          assessment_id: "123",
                          term: "100",
                          indicators: ({ abc: "123" }),
                          disease_ids: ""
                        }
                      )
                  }
                )
            )
            assert_response(:redirect)
            assert_redirected_to(root_path)
          end
        end
      end
      describe("when the disease_ids have been tampered with") do
        it("responds with a flash message and redirect") do
          post(
            plans_url,
            params:
              (
                {
                  plan:
                    (
                      {
                        assessment_id: "123",
                        term: "100",
                        indicators: ({ abc: "123" }),
                        disease_ids: "0"
                      }
                    )
                }
              )
          )
          assert_response(:redirect)
          expect(flash[:notice]).to(
            eq(Exceptions::InvalidDiseasesError.new.message)
          )
          assert_redirected_to(root_path)
        end
      end
    end
    describe("#show") do
      let(:plan) { create(:plan) }
      it("is connected as /plans/id") do
        assert_routing(
          "/plans/#{plan.id}",
          controller: "plans",
          action: "show",
          id: plan.id.to_s
        )
      end
      it("redirects for an invalid plan ID") do
        get(plan_url(123))
        assert_response(:redirect)
        assert_redirected_to(root_path)
      end
      describe("with logged in user") do
        it("responds with success") do
          plan = create(:plan_nigeria_jee1, :with_user)
          sign_in(plan.user)
          get(plan_url(plan))
          assert_response(:success)
          assert_template(:show)
        end
      end
      describe("with logged out user") do
        describe("viewing someone else's plan") do
          it("redirects away") do
            plan = create(:plan_nigeria_jee1)
            get(plan_url(plan))
            assert_response(:redirect)
            assert_redirected_to(root_path)
          end
        end
      end
    end
  end
end
