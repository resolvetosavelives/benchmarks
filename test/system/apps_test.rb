require "application_system_test_case"
require "capybara/cuprite"
require "capybara/minitest/spec"

class AppsTest < ApplicationSystemTestCase
  test "visiting the index" do
    Capybara.current_driver = :cuprite
    Capybara.javascript_driver = :cuprite
    visit root_url
    select "Armenia", from: "country"
    find("button").trigger(:click)
    assert page.has_content?("Let's get started on Armenia")
    select "spar_2018", from: "assessment_type"
    find("#assessment-select-menu button").trigger(:click)
    assert_current_path(/goals\/Armenia\/spar_2018/)
   end
end
