require File.expand_path("./test/test_helper")

class GoalsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @fake = Minitest::Mock.new
    @plan = Plan.new(id: 12)
    @goal_params = ActionController::Parameters.new({assessment_type: "spar_2018"})
  end

  # TODO: GVT: redo this test case to work with the new db tables
  #test "session[:plan_id] does not get set when the user is logged in" do
  #  user = User.new(email: 'test@example.com')
  #
  #  @fake.expect(:call, @plan, [@goal_params, Object, BenchmarksFixture, user])
  #
  #  sign_in user
  #
  #  GoalForm.stub :create_draft_plan!, @fake do
  #    post goals_url, params: {goal_form: {assessment_type: "spar_2018"}}
  #    assert_nil session[:plan_id]
  #  end
  #end

  test "viewing a goal form" do
    get "/goals/Australia/jee1"
    assert_response :ok
    assert_select 'form[data-controller="score"][data-action="submit->score#submit"][data-target="score.form"]', 1
    # there are a total of 96 score and goal fields for this assessment
    assert_select 'input[data-action="change->score-and-goal#validatePair"]', 96
    assert_select 'input[type="submit"][data-target="score.submitButton"]', 1
  end

  test "viewing a goal form created from list of capacities" do
    get "/goals/Australia/from-technical-areas?technical_area_ids[]=spar_2018_ta_c5&technical_area_ids[]=spar_2018_ta_c6"
    # there are a total of 5 score and goal fields for this assessment
    assert_select 'input[type="number"][data-goal="true"]', 5
    assert_select 'input[type="number"][data-goal="false"]', 5
  end
end
