require(File.expand_path("./test/test_helper"))
class CostsheetsControllerTest < ActionDispatch::IntegrationTest
  include(Devise::Test::IntegrationHelpers)
  before do
    @plan = create(:plan, :with_user)
    @non_extant_plan_id = 987_654_321
  end
  it("costsheets#show redirects logged out user") do
    get(costsheet_path(@non_extant_plan_id))
    assert_response(:redirect)
    assert_redirected_to(new_user_session_path)
  end
  it(
    "costsheets#show redirects a user who does not have access to the specified plan"
  ) do
    user = create(:user)
    sign_in(user)
    get(costsheet_path(@plan.id))
    assert_response(:redirect)
    assert_redirected_to(plans_path)
  end
  it("costsheets#show redirects a logged in user if a plan does not exist") do
    user = create(:user)
    sign_in(user)
    get(costsheet_path(@non_extant_plan_id))
    assert_response(:redirect)
    assert_redirected_to(plans_path)
  end
  it("costsheets#show provides an excel sheet if the plan exists") do
    user = @plan.user
    sign_in(user)
    costsheet_stub = stub(to_s: "")
    CostSheet.stubs(:new).returns(costsheet_stub)
    get(costsheet_path(@plan.id))
    assert_response(:success)
  end
end
