require File.expand_path("./test/test_helper")

class WorksheetsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @plan = create(:plan, :with_user)
    @non_extant_plan_id = 987_654_321
  end

  test "worksheets#show redirects logged out user" do
    get worksheet_path(@non_extant_plan_id)
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  test "worksheets#show redirects a user who does not have access to the specified plan" do
    user = create(:user)
    sign_in user
    get worksheet_path(@plan.id)
    assert_response :redirect
    assert_redirected_to plans_path
  end

  test "worksheets#show redirects a logged in user if a plan does not exist" do
    user = @plan.user
    sign_in user
    get worksheet_path(@non_extant_plan_id)
    assert_response :redirect
    assert_redirected_to plans_path
  end

  test "worksheets#show provides an excel sheet if the plan exists" do
    user = @plan.user
    sign_in user
    worksheet_stub = stub(to_s: "") # uses Mocha
    Worksheet.stubs(:new).returns(worksheet_stub)

    get worksheet_path(@plan.id)
    assert_response :success
  end
end
