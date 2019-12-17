require File.expand_path("./test/test_helper")

class CostsheetsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "costsheets#show redirects logged out user" do
    get costsheet_path(1)
    assert_response :redirect
  end

  test "costsheets#show redirects a user who does not have access to the specified plan" do
    plan = create(:plan_nigeria_jee1, :with_user)
    user = create(:user)
    sign_in user
    get costsheet_path(plan.id)
    assert_response :redirect
  end

  test "costsheets#show redirects a logged in user if a plan does not exist" do
    user = User.new email: "test@example.com"
    sign_in user
    get costsheet_path(1)
    assert_response :redirect
  end

  test "costsheets#show provides an excel sheet if the plan exists" do
    plan = create(:plan_nigeria_jee1, :with_user)
    user = plan.user
    sign_in user

    CostSheet.stub :new, CostSheetStub.new do
      get costsheet_path(plan.id)
      assert_response :ok
    end
  end
end

class CostSheetStub
  def to_s
    RubyXL::Workbook.new.stream.string
  end
end
