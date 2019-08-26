require "minitest/autorun"

def create_draft_plan_stub
  plan = Plan.create(name: "test plan", activity_map: [])
  GoalForm.stub :create_draft_plan!, plan do
    post goals_url, params: {goal_form: { assessment_type: "jee1"}}
    yield plan.id
  end
end

class PlansControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "plan#show redirects logged out user without session[:plan_id]" do
    get plan_path(1)
    assert_response :redirect
  end

  test "redirects logged out user with mismatched session[:plan_id]" do
    create_draft_plan_stub do |plan_id|
      get plan_path("another plan")
      assert_response :redirect
    end
  end

  test "logged out user can access a plan matching session[:plan_id]" do
    create_draft_plan_stub do |plan_id|
      get plan_path(plan_id)
      assert_response :ok
    end
  end

  test "logged in user can see their plan" do
    plan = Plan.create(name: "a plan", activity_map: [])
    user = User.new(email: 'test@example.com')
    user.plans << plan
    sign_in user
    get plan_path(plan.id)
    assert_response :ok
  end

  test "logged in user can't see someone else's plan" do
    plan = Plan.create(name: "a plan", activity_map: [])
    user = User.new(email: 'test@example.com')
    sign_in user
    get plan_path(plan.id)
    assert_response :redirect
  end

  test "logged in user can update their plan" do
    plan = Plan.create(name: "a draft plan", activity_map: [])
    user = User.new(email: 'test@example.com')
    user.plans << plan
    sign_in user
    put plan_path(plan.id), params: { plan: {name: "the plan", activity_map: "[]"}}
    assert_equal Plan.find_by_name("the plan").id, plan.id
  end

  test "logged in user can't update someone else's plan" do
    plan = Plan.create(name: "a draft plan", activity_map: [])
    user = User.new(email: 'test@example.com')
    sign_in user
    put plan_path(plan.id), params: { plan: {name: "the plan", activity_map: "[]"}}
    assert_redirected_to root_path
    assert_equal Plan.where(name: "the plan").count, 0
  end

  test "logged out user can't update a plan with id != session[:plan_id]" do
    create_draft_plan_stub do |plan_id|
      put plan_path("another plan"), params: { plan: { name: "different" }}
      assert_redirected_to root_path
    end
  end

  test "logged out user can update a plan with id == session[:plan_id]" do
    create_draft_plan_stub do |plan_id|
      put plan_path(plan_id), params: { plan: { name: "different", activity_map: "[]" }}
      follow_redirect!
      assert_redirected_to new_user_session_path
      assert_equal Plan.find_by_name("different").id, plan_id
    end
  end

  test "logged out user can't see a list of plans" do
    get plans_path
    assert_redirected_to new_user_session_path
  end

  test "logged in user sees a list of their plans" do
    user = User.create!(email: 'test@example.com', password: "123455", role: "Donor")
    plan1 = Plan.create!(name: "owned plan", activity_map: [])
    user.plans << plan1
    Plan.create!(name: "orphan", activity_map: [])

    sign_in user
    get plans_path
    assert_response :ok
    assert_select ".plan-entry", 1

    user.plans.first.destroy
    get plans_path
    assert_select ".plan-entry", 0
  end
end
