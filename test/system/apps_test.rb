require 'application_system_test_case'
require 'capybara/cuprite'
require 'capybara/minitest/spec'

class AppsTest < ApplicationSystemTestCase
  setup do
    Capybara.current_driver = :cuprite
    Capybara.javascript_driver = :cuprite
  end

  test 'happy path test' do
    visit root_url
    select 'Armenia', from: 'country'
    find('button').trigger(:click)
    assert page.has_content?("LET'S GET STARTED ON ARMENIA")
    select 'SPAR 2018', from: 'assessment_type'
    find('#assessment-select-menu button').trigger(:click)
    assert_current_path(%r{goals\/Armenia\/spar_2018})

    assert page.has_content?('SPAR 2018 SCORES')
    assert page.has_content?(
             'Financing mechanism and funds for timely response to public health emergencies'
           )
    assert_equal '3', find('#goal_form_spar_2018_ind_c13').value
    assert_equal '4', find('#goal_form_spar_2018_ind_c13_goal').value

    find('#new_goal_form input[type=submit]').trigger(:click)

    assert_current_path(%r{plans\/\d+})
    assert_equal 'Armenia draft plan', find('#plan_name').value

    assert page.has_content?(
             'Document and disseminate information on the timely distribution and effective use of funds to increase health security (such as preventing or stopping the spread of disease), at the national and subnational levels in all relevant ministries or sectors.'
           )
    find('#plan_name').fill_in with: 'Updated Draft Plan'
    find('input[type=submit]').trigger(:click)

    assert_current_path('/users/sign_in')
    find('#user_email').fill_in with: 'savanni@cloudcity.io'
    find('#user_password').fill_in with: '6hU$no8IlS8*'
    find('#new_user input[type=submit]').trigger(:click)

    assert_current_path('/plans')
    assert page.has_content?('WELCOME')
    assert page.has_content?('Updated Draft Plan')
  end
end
