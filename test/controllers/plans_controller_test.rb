require File.expand_path("./test/test_helper")

class PlansControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  describe PlansController do
    describe "#goals" do
      describe "for a non-existent assessment" do
        it "responds with success" do
          get plan_goals_url(
                {
                  country_name: "Xyz",
                  assessment_type: "jee1",
                  plan_term: "5-year",
                },
              )
          assert_response :success
        end
      end

      describe "for JEE1 5-year" do
        it "responds with success" do
          get plan_goals_url(
                {
                  country_name: "Nigeria",
                  assessment_type: "jee1",
                  plan_term: "5-year",
                },
              )
          assert_response :success
        end
      end

      describe "for SPAR 2018 1-year" do
        it "responds with success" do
          get plan_goals_url(
                {
                  country_name: "Nigeria",
                  assessment_type: "spar_2018",
                  plan_term: "1-year",
                },
              )
          assert_response :success
        end
      end

      describe "for JEE1 5-year plan by selected areas" do
        it "responds with success" do
          get plan_goals_url(
                {
                  country_name: "Nigeria",
                  assessment_type: "jee1",
                  plan_term: "1-year",
                  technical_area_ids: "2-4-9",
                },
              )
          assert_response :success
        end
      end
    end

    describe "#create" do
      describe "when the plan is saved" do
        before do
          plan.stubs(:persisted?).returns(true)
          plan.stubs(:id).returns(123)
        end
        let(:plan) { Plan.new }

        it "responds with success" do
          Plan.expects(:create_from_goal_form).with do |value|
            value[:is_5_year_plan].eql?(false)
          end.returns(plan)
          post plans_url,
               params: {
                 plan: {
                   assessment_id: "123",
                   term: "100",
                   indicators: { abc: "123" },
                   disease_ids: "",
                 },
               }
          assert_response :redirect
          assert_redirected_to plan_path(plan.id)
        end

        describe "for a 5-year plan" do
          it "responds with success" do
            Plan.expects(:create_from_goal_form).with do |value|
              value[:is_5_year_plan].eql?(true)
            end.returns(plan)
            post plans_url,
                 params: {
                   plan: {
                     assessment_id: "123",
                     term: "500",
                     indicators: { abc: "123" },
                     disease_ids: "10",
                   },
                 }
            assert_response :redirect
            assert_redirected_to plan_path(plan.id)
          end
        end
      end

      describe "when the plan is not saved" do
        it "responds with a redirect" do
          plan = Plan.new
          Plan.stub(:create_from_goal_form, plan) do
            post plans_url,
                 params: {
                   plan: {
                     assessment_id: "123",
                     term: "100",
                     indicators: { abc: "123" },
                     disease_ids: "",
                   },
                 }
            assert_response :redirect
            assert_redirected_to root_path
          end
        end
      end

      describe "when the disease_ids have been tampered with" do
        it "responds with a flash message and redirect" do
          post plans_url,
               params: {
                 plan: {
                   # 0 does not exist as a disease id
                   assessment_id: "123",
                   term: "100",
                   indicators: { abc: "123" },
                   disease_ids: "0",
                 },
               }
          assert_response :redirect
          assert_equal Exceptions::InvalidDiseasesError.new.message,
                       flash[:notice]
          assert_redirected_to root_path
        end
      end
    end

    describe "#show" do
      let(:plan) { create(:plan) }

      it "is connected as /plans/id" do
        assert_routing(
          "/plans/#{plan.id}",
          { controller: "plans", action: "show", id: plan.id.to_s },
        )
      end

      it "redirects for an invalid plan ID" do
        get plan_url(123)

        assert_response :redirect
        assert_redirected_to root_path
      end

      describe "with logged in user" do
        it "responds with success" do
          plan = create(:plan_nigeria_jee1, :with_user)
          sign_in plan.user

          get plan_url(plan)

          assert_response :success
          assert_template :show
        end
      end

      describe "with logged out user" do
        describe "viewing someone else's plan" do
          it "redirects away" do
            plan = create(:plan_nigeria_jee1)

            get plan_url(plan)

            assert_response :redirect
            assert_redirected_to root_path
          end
        end
      end
    end
  end

  #test "logged in user can update their plan" do
  #  plan = create(:plan_nigeria_jee1, :with_user)
  #  sign_in plan.user
  #  put plan_path(plan.id),
  #    params: {plan: {name: "the plan", benchmark_action_ids: "[]"}}
  #  assert_equal Plan.find_by_name("the plan").id, plan.id
  #end
  #
  #test "logged in user can't update someone else's plan" do
  #  plan = create(:plan_nigeria_jee1, :with_user)
  #  other_user = create(:user)
  #  sign_in other_user
  #  put plan_path(plan.id),
  #    params: {plan: {name: "the plan", action_map: "{}"}}
  #  assert_redirected_to root_path
  #  assert_equal Plan.where(name: "the plan").count, 0
  #end
  #
  ## TODO: GVT: redo this test case to work with the new db tables
  ## test "logged out user can't update a plan with id != session[:plan_id]" do
  ##  create_draft_plan_stub do |plan_id|
  ##    put plan_path('another plan'), params: { plan: { name: 'different' } }
  ##    assert_redirected_to root_path
  ##  end
  ## end
  #
  ## TODO: GVT: redo this test case to work with the new db tables
  ## test 'logged out user can update a plan with id == session[:plan_id]' do
  ##  create_draft_plan_stub do |plan_id|
  ##    put plan_path(plan_id),
  ##        params: { plan: { name: 'different', action_map: '{}' } }
  ##    follow_redirect!
  ##    assert_redirected_to new_user_session_path
  ##    assert_equal Plan.find_by_name('different').id, plan_id
  ##  end
  ## end
  #
  #test "logged out user can't see a list of plans" do
  #  get plans_path
  #  assert_redirected_to new_user_session_path
  #end
  #
  #test "logged in user sees a list of their plans" do
  #  plan = create(:plan_nigeria_jee1, :with_user)
  #  user = plan.user
  #  # create other plan which will have no user
  #  create(:plan_nigeria_jee1)
  #
  #  sign_in user
  #  get plans_path
  #  assert_response :ok
  #  assert_select ".plan-entry", 1
  #  assert_select "form#assessment-select-menu[data-target='assessment-selection.form']",
  #    1
  #
  #  user.plans.first.destroy
  #  get plans_path
  #  assert_select ".plan-entry", 0
  #end
  #
  #test "user deletes their plan" do
  #  plan = create(:plan_nigeria_jee1, :with_user)
  #  user = plan.user
  #  sign_in user
  #
  #  delete plan_path(plan.id)
  #  assert_equal 0, user.reload.plans.length
  #end
  #
  #test "user deletes someone else's plan" do
  #  plan = create(:plan_nigeria_jee1, :with_user)
  #  other_user = create(:user)
  #  before_plan_count = Plan.count
  #  sign_in other_user
  #
  #  delete plan_path(plan.id)
  #  assert_equal before_plan_count, Plan.count
  #end
end
