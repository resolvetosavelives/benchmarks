require File.expand_path("./test/test_helper")

class WorksheetsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "worksheets#show redirects logged out user" do
    get worksheet_path(1)
    assert_response :redirect
  end

  test "worksheets#show redirects a user who does not have access to the specified plan" do
    plan = create(:plan_nigeria_jee1)
    user = create(:user)
    sign_in user
    get worksheet_path(plan.id)
    assert_response :redirect
  end

  test "worksheets#show redirects a logged in user if a plan does not exist" do
    plan = create(:plan_nigeria_jee1, :with_user)
    user = plan.user
    sign_in user
    get worksheet_path(1)
    assert_response :redirect
  end

  test "worksheets#show provides an excel sheet if the plan exists" do
    plan = create(:plan_nigeria_jee1, :with_user)
    user = plan.user
    sign_in user

    Worksheet.stub :new, WorksheetStub.new do
      get worksheet_path(plan.id)
      assert_response :ok
    end
  end
end

class WorksheetStub
  def to_s
    RubyXL::Workbook.new.stream.string
  end
end
