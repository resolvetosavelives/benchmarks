require 'minitest/autorun'

class WorksheetsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'worksheets#show redirects logged out user' do
    get worksheet_path(1)
    assert_response :redirect
  end

  test 'worksheets#show redirects a user who does not have access to the specified plan' do
    plan = Plan.create name: 'a plan', activity_map: {}
    user = User.new email: 'test@example.com'
    sign_in user
    get worksheet_path(plan.id)
    assert_response :redirect
  end

  test 'worksheets#show redirects a logged in user if a plan does not exist' do
    user = User.new email: 'test@example.com'
    sign_in user
    get worksheet_path(1)
    assert_response :redirect
  end

  test 'worksheets#show provides an excel sheet if the plan exists' do
    plan = Plan.create! name: 'a plan', activity_map: {}
    user = User.new email: 'test@example.com'
    user.plans << plan
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
