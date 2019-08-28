require 'application_system_test_case'
require 'capybara/cuprite'
require 'capybara/minitest/spec'

class AppsTest < ApplicationSystemTestCase
  setup do
    Capybara.current_driver = :cuprite
    Capybara.javascript_driver = :cuprite
  end

  test 'visiting the index' do
    skip
    visit root_url
    select 'Armenia', from: 'country'
    find('button').trigger(:click)
    assert page.has_content?("Let's get started on Armenia")
    select 'spar_2018', from: 'assessment_type'
    find('#assessment-select-menu button').trigger(:click)
    assert_current_path(%r{goals\/Armenia\/spar_2018})
  end

  test 'visit a SPAR 2018 assessment page' do
    visit '/goals/Armenia/spar_2018'
    assert_current_path(%r{goals\/Armenia\/spar_2018})
    assert page.has_content?('spar_2018 Scores')
    assert page.has_content?(
             'Financing mechanism and funds for timely response to public health emergencies'
           )
    assert_equal '60', find('#goal_form_spar_2018_ind_c13').value
    assert_equal '80', find('#goal_form_spar_2018_ind_c13_goal').value

    find('#new_goal_form input[type=submit]').trigger(:click)

    assert_current_path(%r{plans\/\d+})
    assert_equal 'Armenia draft plan', find('#plan_name').value
  end
end
