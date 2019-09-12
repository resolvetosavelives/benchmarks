require 'minitest/autorun'

def create_draft_plan_stub
  plan = Plan.create(name: 'test plan', activity_map: {})
  GoalForm.stub :create_draft_plan!, plan do
    post goals_url, params: { goal_form: { assessment_type: 'jee1' } }
    yield plan.id
  end
end

class PlansControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'plan#show redirects logged out user without session[:plan_id]' do
    get plan_path(1)
    assert_response :redirect
  end

  test 'redirects logged out user with mismatched session[:plan_id]' do
    create_draft_plan_stub do |plan_id|
      get plan_path('another plan')
      assert_response :redirect
    end
  end

  test 'logged out user can access a plan matching session[:plan_id]' do
    create_draft_plan_stub do |plan_id|
      get plan_path(plan_id)
      assert_response :ok
    end
  end

  test 'logged in user can see their plan' do
    plan = Plan.create(name: 'a plan', activity_map: {})
    user = User.new(email: 'test@example.com')
    user.plans << plan
    sign_in user
    get plan_path(plan.id)
    assert_response :ok
    assert_select '.capacity-container', 18
  end

  test "logged in user can't see someone else's plan" do
    plan = Plan.create(name: 'a plan', activity_map: {})
    user = User.new(email: 'test@example.com')
    sign_in user
    get plan_path(plan.id)
    assert_response :redirect
  end

  test 'plan/show.html.erb wires up plan controller correctly' do
    plan =
      Plan.create(
        name: 'a plan',
        activity_map: {
          '1.1' => [{ "text": 'Activity 1' }, { "text": 'Activity 2' }]
        }
      )
    user = User.new(email: 'test@example.com')
    user.plans << plan
    sign_in user
    get plan_path(plan.id)
    assert_select '.plan-container[data-controller="plan"]', 1
    assert_select 'form[data-target="plan.form"]', 1
    assert_select 'input[data-target="plan.name"][data-action="change->plan#validateName"]',
                  1
    assert_select 'input[data-target="plan.activityMap"]', 1
    assert_select 'input[data-target="plan.newActivity"][data-action="keypress->plan#addNewActivity"][data-benchmark-id="1.1"]',
                  1
    assert_select 'button[data-action="plan#deleteActivity"][data-benchmark-id="1.1"]',
                  2
  end

  test 'logged in user can update their plan' do
    plan = Plan.create(name: 'a draft plan', activity_map: {})
    user = User.new(email: 'test@example.com')
    user.plans << plan
    sign_in user
    put plan_path(plan.id),
        params: { plan: { name: 'the plan', activity_map: '{}' } }
    assert_equal Plan.find_by_name('the plan').id, plan.id
  end

  test "logged in user can't update someone else's plan" do
    plan = Plan.create(name: 'a draft plan', activity_map: {})
    user = User.new(email: 'test@example.com')
    sign_in user
    put plan_path(plan.id),
        params: { plan: { name: 'the plan', activity_map: '{}' } }
    assert_redirected_to root_path
    assert_equal Plan.where(name: 'the plan').count, 0
  end

  test "logged out user can't update a plan with id != session[:plan_id]" do
    create_draft_plan_stub do |plan_id|
      put plan_path('another plan'), params: { plan: { name: 'different' } }
      assert_redirected_to root_path
    end
  end

  test 'logged out user can update a plan with id == session[:plan_id]' do
    create_draft_plan_stub do |plan_id|
      put plan_path(plan_id),
          params: { plan: { name: 'different', activity_map: '{}' } }
      follow_redirect!
      assert_redirected_to new_user_session_path
      assert_equal Plan.find_by_name('different').id, plan_id
    end
  end

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
    user =
      User.create!(email: 'test@example.com', password: '123455', role: 'Donor')
    plan = Plan.create!(name: 'owned plan', activity_map: {})
    user.plans << plan

    sign_in user
    delete plan_path(plan.id)
    assert_equal 0, user.reload.plans.length
  end

  test "user deletes someone else's plan" do
    user =
      User.create!(email: 'test@example.com', password: '123455', role: 'Donor')
    plan = Plan.create!(name: 'a plan', activity_map: {})

    sign_in user
    delete plan_path(plan.id)
    assert_equal 1, Plan.count
  end
end
