require "minitest/mock"

class GoalsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @fake = Minitest::Mock.new
    @plan = Plan.new(id: 12)
    @goal_params = ActionController::Parameters.new({assessment_type: "spar_2018"})
  end

  test "creates a plan when goals are submitted" do
    @fake.expect(:call, @plan, [@goal_params, Object, BenchmarksFixture, JeeScale, nil])

    GoalForm.stub :create_draft_plan!, @fake do
      post goals_url, params: {goal_form: {assessment_type: "spar_2018"}}
      assert_response :redirect
      assert_equal session[:plan_id], 12
    end
  end

  test "session[:plan_id] does not get set when the user is logged in" do
    user = User.new(email: 'test@example.com')

    @fake.expect(:call, @plan, [@goal_params, Object, BenchmarksFixture, JeeScale, user])

    sign_in user

    GoalForm.stub :create_draft_plan!, @fake do
      post goals_url, params: {goal_form: {assessment_type: "spar_2018"}}
      assert_nil session[:plan_id]
    end
  end
end
