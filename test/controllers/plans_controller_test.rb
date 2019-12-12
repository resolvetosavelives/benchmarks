require File.expand_path('./test/test_helper')
require 'minitest/autorun'

class PlansControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "#create plan checks that its saved and response is redirect" do
    plan = create(:plan_nigeria_jee1)
    Plan.stub(:from_goal_form, plan) do
      post plans_path, params: {
          "goal_form" => {
              "country"                => "Nigeria",
              "assessment_type"        => "from-capacities",
              "spar_2018_ind_c21"      => "1",
              "spar_2018_ind_c21_goal" => "2",
          }
      }
    end
    assert_response :redirect
    assert_redirected_to plan_path plan
  end

  test "#create plan failure checks that its unsaved and response is redirect back" do
    plan = build(:plan_nigeria_jee1)
    Plan.stub(:from_goal_form, plan) do
      post plans_path, params: {
          "goal_form" => {
              "country"                => "Nigeria",
              "assessment_type"        => "from-capacities",
              "spar_2018_ind_c21"      => "1",
              "spar_2018_ind_c21_goal" => "2",
          }
      }
    end
    assert_response :redirect
    assert_redirected_to root_path
  end

  test 'plan#show redirects logged out user without session[:plan_id]' do
    get plan_path(1)
    assert_response :redirect
  end

  test 'plan#show responds with success for assessment_type jee1' do
    plan = create(:plan_nigeria_jee1, :with_user)
    sign_in plan.user
    get plan_path(plan.id)
    assert_response :success
  end

  test 'plan#show responds with success for assessment_type spar_2018' do
    plan = create(:plan_nigeria_jee1, :with_user)
    sign_in plan.user
    get plan_path(plan.id)
    assert_response :success
  end

  test 'plan#show responds with success for assessment_type from-capacities' do
    plan = create(:plan, :with_user)
    sign_in plan.user
    get plan_path(plan.id)
    assert_response :success
  end

  test 'logged in user can see their plan' do
    plan = create(:plan_nigeria_jee1, :with_user)
    sign_in plan.user
    get plan_path(plan.id)
    assert_response :ok
    assert_select '.technical-area-container', 18
  end

  test "logged in user can't see someone else's plan" do
    plan = create(:plan_nigeria_jee1, :with_user)
    other_user = User.new(email: 'test@example.com')
    sign_in other_user
    get plan_path(plan.id)
    assert_response :redirect
  end

  # TODO: GVT: not working until the add activities form is working again
  #test 'plan/show.html.erb wires up plan controller correctly' do
  #  plan = create(:plan, :with_user)
  #  sign_in plan.user
  #  get plan_path(plan.id)
  #  #puts "GVT: response: #{response.body}"
  #  assert_select '.plan-container[data-controller="plan"]', 1
  #  assert_select 'form[data-target="plan.form"]', 1
  #  assert_select 'input[data-target="plan.name"][data-action="change->plan#validateName"]',
  #                1
  #  assert_select 'input[data-target="plan.activityMap"]', 1
  #  assert_select 'input[data-target="plan.newActivity"][data-action="keypress->plan#addNewActivity"][data-benchmark-id="1.1"]',
  #                1
  #  assert_select 'button[data-action="plan#deleteActivity"][data-benchmark-id="1.1"]',
  #                2
  #end

  test 'logged in user can update their plan' do
    plan = create(:plan_nigeria_jee1, :with_user)
    sign_in plan.user
    put plan_path(plan.id),
        params: { plan: { name: 'the plan', benchmark_activity_ids: '[]' } }
    assert_equal Plan.find_by_name('the plan').id, plan.id
  end

  test "logged in user can't update someone else's plan" do
    plan = create(:plan_nigeria_jee1, :with_user)
    other_user = create(:user)
    sign_in other_user
    put plan_path(plan.id),
        params: { plan: { name: 'the plan', activity_map: '{}' } }
    assert_redirected_to root_path
    assert_equal Plan.where(name: 'the plan').count, 0
  end

  # TODO: GVT: redo this test case to work with the new db tables
  #test "logged out user can't update a plan with id != session[:plan_id]" do
  #  create_draft_plan_stub do |plan_id|
  #    put plan_path('another plan'), params: { plan: { name: 'different' } }
  #    assert_redirected_to root_path
  #  end
  #end

  # TODO: GVT: redo this test case to work with the new db tables
  #test 'logged out user can update a plan with id == session[:plan_id]' do
  #  create_draft_plan_stub do |plan_id|
  #    put plan_path(plan_id),
  #        params: { plan: { name: 'different', activity_map: '{}' } }
  #    follow_redirect!
  #    assert_redirected_to new_user_session_path
  #    assert_equal Plan.find_by_name('different').id, plan_id
  #  end
  #end

  test "logged out user can't see a list of plans" do
    get plans_path
    assert_redirected_to new_user_session_path
  end

  test 'logged in user sees a list of their plans' do
    user =
      User.create!(email: 'test@example.com', password: '123455', role: 'Donor')
    plan1 = Plan.create!(name: 'owned plan', activity_map: {})
    user.plans << plan1
    Plan.create!(name: 'orphan', activity_map: {})

    sign_in user
    get plans_path
    assert_response :ok
    assert_select '.plan-entry', 1
    assert_select "form#assessment-select-menu[data-target='assessment-selection.form']",
                  1

    user.plans.first.destroy
    get plans_path
    assert_select '.plan-entry', 0
  end

  test 'user deletes their plan' do
    plan = create(:plan_nigeria_jee1, :with_user)
    user = plan.user
    sign_in user

    delete plan_path(plan.id)
    assert_equal 0, user.reload.plans.length
  end

  test "user deletes someone else's plan" do
    plan = create(:plan_nigeria_jee1, :with_user)
    other_user = create(:user)
    before_plan_count = Plan.count
    sign_in other_user

    delete plan_path(plan.id)
    assert_equal before_plan_count, Plan.count
  end
end
