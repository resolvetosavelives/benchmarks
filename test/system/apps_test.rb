require File.expand_path('./test/application_system_test_case')
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
             'C1.3 Financing mechanism and funds for timely response to public health emergencies'
           )
    assert_equal '3', find('#goal_form_spar_2018_ind_c13').value
    assert_equal '4', find('#goal_form_spar_2018_ind_c13_goal').value

    find('#new_goal_form input[type=submit]').trigger(:click)

    assert_current_path(%r{plans\/\d+})
    assert_equal 'Armenia draft plan', find('#plan_name').value
    assert page.has_content?('TOTAL ACTIVITIES')
    # activity count was 103 but became 98 along with refactoring changes, I think due to bug(s) fixed
    assert_equal '98', find('.activity-count-circle span').text

    assert page.has_content?(
             'Document and disseminate information on the timely distribution and effective use of funds to increase health security (such as preventing or stopping the spread of disease), at the national and subnational levels in all relevant ministries or sectors.'
           )
    find('#plan_name').fill_in with: 'Updated Draft Plan'
    find('input[type=submit]').trigger(:click)

    assert_current_path('/users/sign_in')
    click_link('Create an account')

    assert_current_path('/users/sign_up')
    sleep 0.1  # ugh without this form field(s) dont get filled
    find('#user_email').fill_in with: 'email@example.com'
    find('#user_password').fill_in with: '123123'
    find('#user_password_confirmation').fill_in with: '123123'
    find('#new_user input[type=submit]').trigger(:click)

    assert_current_path('/plans')
    assert page.has_content?('WELCOME')
    assert page.has_content?('Updated Draft Plan')
  end
end
