require File.expand_path("./test/application_system_test_case")

class AppsTest < ApplicationSystemTestCase
  setup do
    Capybara.current_driver = :cuprite
    Capybara.javascript_driver = :cuprite
  end

  test "happy path for Nigeria JEE 1.0" do
    ##
    # visit home page
    visit root_url
    click_on("Get Started")

    ##
    # navigate to Get Started page and submit its form
    assert_current_path("/get-started")
    assert page.has_content?("LET'S GET STARTED")
    select_from_chosen("Nigeria", from: "get_started_form_country_id")
    choose "Joint External Evaluation (JEE)"
    choose "1 year plan"

    # the following selection + assertion is done to verify fix of the
    # the bug reported here: https://www.pivotaltracker.com/story/show/171721472
    select_from_chosen("Angola", from: "get_started_form_country_id")
    assert_current_path("/get-started")

    select_from_chosen("Nigeria", from: "get_started_form_country_id")
    choose "Joint External Evaluation (JEE)"
    choose "1 year plan"
    click_on("Next")

    ##
    # turn up on the Goal-setting page for the selected options and hit save
    assert_current_path("/plan/goals/Nigeria/jee1/1-year")
    assert page.has_content?("JEE SCORES")
    assert page.has_content?(
             "P.1.1 Legislation, laws, regulations, administrative requirements, policies or other government instruments in place are sufficient for implementation of IHR (2005)",
           )
    assert page.has_content?(
             "RE.2 Enabling environment in place for management of radiation emergencies",
           )
    assert_equal "1", find("#plan_indicators_jee1_ind_p11").value
    assert_equal "2", find("#plan_indicators_jee1_ind_p11_goal").value
    find("#new_plan input[type=submit]").trigger(:click)

    ##
    # wind up on the View Plan page after the plan has been saved, and then make an edit
    assert_current_path(%r{^\/plans\/\d+$})
    assert_equal "Nigeria draft plan", find("#plan_name").value
    assert page.has_content?("TOTAL ACTIONS")
    assert_equal "235", find(".action-count-circle span").text
    assert_selector("#technical-area-1") # the first one
    assert_selector("#technical-area-3") # the last one
    assert_selector(".nudge-container") do
      assert page.has_content?(
               # nudge content for 1-year plan
               "Focus on no more than 2-3 actions per technical area",
             )
    end

    ##
    # save the state_from_server to file, for use in jest tests.
    # uncomment and run this to update the JSON data file periodically or upon STATE_FROM_SERVER structure/format change.
    # save_state_from_server(page)

    # verify bar chart by technical area filter functionality
    find("line[data-original-title*=\"Antimicrobial Resistance\"]").click
    assert_selector("#technical-area-3") # the last one
    assert_no_selector("#technical-area-1") # the first one

    # un-filter to show all
    find(".action-count-circle").click
    assert_selector("#technical-area-1")
    assert_selector("#technical-area-18")

    # edit the plan name and hit save button
    find("#plan_name").fill_in with: "Saved Nigeria Plan 789"
    find("input[type=submit]").trigger(:click)

    ##
    # wind up on sign-in page and go to create an account
    assert_current_path("/users/sign_in")
    click_link("Create an account")

    ##
    # wind up on create account page
    assert_current_path("/users/sign_up")
    sleep 0.1
    find("#user_email").fill_in with: "email@example.com"
    find("#user_password").fill_in with: "123123"
    find("#user_password_confirmation").fill_in with: "123123"
    find("#new_user input[type=submit]").trigger(:click)

    ##
    # wind up on create account page
    assert_current_path("/plans")
    assert page.has_content?("Welcome! You have signed up successfully.")
    assert page.has_content?("Saved Nigeria Plan 789") # ugh without this form field(s) dont get filled
  end

  test "happy path for Nigeria JEE 1.0 with influenzas" do
    ##
    # visit home page
    visit root_url
    click_on("Get Started")

    ##
    # navigate to Get Started page and submit its form
    assert_current_path("/get-started")
    assert page.has_content?("LET'S GET STARTED")
    select_from_chosen("Nigeria", from: "get_started_form_country_id")
    choose "Joint External Evaluation (JEE)"
    choose "1 year plan"

    # the following selection + assertion is done to verify fix of the
    # the bug reported here: https://www.pivotaltracker.com/story/show/171721472
    select_from_chosen("Angola", from: "get_started_form_country_id")
    assert_current_path("/get-started")

    select_from_chosen("Nigeria", from: "get_started_form_country_id")
    choose "Joint External Evaluation (JEE)"
    choose "1 year plan"
    check "Optional: Influenza planning"
    click_on("Next")

    ##
    # turn up on the Goal-setting page for the selected options and hit save
    assert_current_path("/plan/goals/Nigeria/jee1/1-year?diseases=1")
    assert page.has_content?("JEE SCORES")
    assert page.has_content?(
             "P.1.1 Legislation, laws, regulations, administrative requirements, policies or other government instruments in place are sufficient for implementation of IHR (2005)",
           )
    assert page.has_content?(
             "RE.2 Enabling environment in place for management of radiation emergencies",
           )
    assert_equal "1", find("#plan_indicators_jee1_ind_p11").value
    assert_equal "2", find("#plan_indicators_jee1_ind_p11_goal").value
    find("#new_plan input[type=submit]").trigger(:click)

    ##
    # wind up on the View Plan page after the plan has been saved, and then make an edit
    assert_current_path(%r{^\/plans\/\d+$})
    assert_equal "Nigeria draft plan", find("#plan_name").value
    assert page.has_content?("TOTAL ACTIONS")
    assert_equal "283", find(".action-count-circle span").text
    assert_selector("#technical-area-1") # the first one
    assert_selector("#technical-area-3") # the last one
    assert_selector(".nudge-container") do
      assert page.has_content?(
               # nudge content for 1-year plan
               "Focus on no more than 2-3 actions per technical area",
             )
    end

    assert_selector("#technical-area-1") do
      assert page.has_content?(
          # nudge content for 1-year plan
          "government instruments relevant to pandemic influenza",
          )
    end

    # verify bar chart by technical area filter functionality
    find("line[data-original-title*=\"Antimicrobial Resistance\"]").click
    assert_selector("#technical-area-3") # the last one
    assert_no_selector("#technical-area-1") # the first one

    # un-filter to show all
    find(".action-count-circle").click
    assert_selector("#technical-area-1")
    assert_selector("#technical-area-18")

    # edit the plan name and hit save button
    find("#plan_name").fill_in with: "Saved Nigeria Plan 789"
    find("input[type=submit]").trigger(:click)

    ##
    # wind up on sign-in page and go to create an account
    assert_current_path("/users/sign_in")
    click_link("Create an account")

    ##
    # wind up on create account page
    assert_current_path("/users/sign_up")
    sleep 0.1
    find("#user_email").fill_in with: "email@example.com"
    find("#user_password").fill_in with: "123123"
    find("#user_password_confirmation").fill_in with: "123123"
    find("#new_user input[type=submit]").trigger(:click)

    ##
    # wind up on create account page
    assert_current_path("/plans")
    assert page.has_content?("Welcome! You have signed up successfully.")
    assert page.has_content?("Saved Nigeria Plan 789") # ugh without this form field(s) dont get filled
  end

  test "happy path for Armenia SPAR 2018 5-year plan" do
    ##
    # start on the home page
    visit root_url
    click_on("Get Started")

    ##
    # go to the Get Started page and fill the form
    assert_current_path("/get-started")
    assert page.has_content?("LET'S GET STARTED")
    select_from_chosen("Armenia", from: "get_started_form_country_id")
    choose "State Party Annual Report (SPAR)"
    choose "5 year plan"
    click_on("Next")

    ##
    # turn up on the plan goal-setting page
    assert_current_path("/plan/goals/Armenia/spar_2018/5-year")
    assert page.has_content?("SPAR SCORES")
    assert page.has_content?(
             "C4.1 Multisectoral collaboration mechanism for food safety events",
           )
    # verify that the 5-year plan has set goal from 2 to 4
    assert_equal "2", find("#plan_indicators_spar_2018_ind_c41").value
    assert_equal "4", find("#plan_indicators_spar_2018_ind_c41_goal").value
    find("#new_plan input[type=submit]").trigger(:click)

    ##
    # wind up on the View Plan page, make an edit, and save the plan
    assert_current_path(%r{^\/plans\/\d+$})
    assert_equal "Armenia draft plan", find("#plan_name").value
    assert page.has_content?("TOTAL ACTIONS")
    # action count was 103 but became 98 along with refactoring changes, I think due to bug(s) fixed
    assert_equal "107", find(".action-count-circle span").text
    assert page.has_content?(
             "Document and disseminate information on the timely distribution and effective use of funds to increase health security (such as preventing or stopping the spread of disease), at the national and subnational levels in all relevant ministries or sectors.",
           )
    find("#plan_name").fill_in with: "Saved Armenia Plan"
    find("input[type=submit]").trigger(:click)

    ##
    # wind up on the Sign In page, go to Create an Account
    assert_current_path("/users/sign_in")
    click_link("Create an account")

    ##
    # at the Create an Account page, fill and submit the form
    assert_current_path("/users/sign_up")
    sleep 0.1
    find("#user_email").fill_in with: "email@example.com"
    find("#user_password").fill_in with: "123123"
    find("#user_password_confirmation").fill_in with: "123123"
    find("#new_user input[type=submit]").trigger(:click)

    ##
    # wind up on the View Plan page, make an edit, and save the plan
    assert_current_path("/plans")
    assert page.has_content?("Welcome! You have signed up successfully.")
    assert page.has_content?("Saved Armenia Plan") # ugh without this form field(s) dont get filled
  end

  test "happy path for Nigeria JEE 1.0 plan by technical areas 5-year" do
    ##
    # start on the home page
    visit root_url
    click_on("Get Started")

    ##
    # go to the Get Started page and fill the form
    assert_current_path("/get-started")
    assert page.has_content?("LET'S GET STARTED")
    select_from_chosen("Nigeria", from: "get_started_form_country_id")
    choose "Joint External Evaluation (JEE)"
    # kludge: must select "5 year plan" after assessment type, otherwise it wont select and
    #   fails form validation. extra weird because that same flow works in the other test cases.
    check "Optional: Plan by technical area(s)"
    sleep 0.1
    check "IHR coordination, communication and advocacy"
    check "Surveillance"
    sleep 0.2
    choose "5 year plan"
    click_on("Next")

    ##
    # turn up on the plan goal-setting page
    assert_current_path("/plan/goals/Nigeria/jee1/5-year?areas=2-9")
    assert page.has_content?("JEE SCORES")
    assert page.has_content?(
             "P.2.1 A functional mechanism is established for the coordination and integration of relevant sectors in the implementation of IHR",
           )
    assert page.has_content?(
             "D.2.1 Indicator- and event-based surveillance systems",
           )
    assert_equal "2", find("#plan_indicators_jee1_ind_p21").value
    # verify that this 5-year plan has goal set to 4 instead of 3
    assert_equal "4", find("#plan_indicators_jee1_ind_p21_goal").value
    find("#new_plan input[type=submit]").trigger(:click)

    ##
    # turn up on the View Plan, make an edit, save the plan
    assert_current_path(%r{^\/plans\/\d+$})
    assert_equal "Nigeria draft plan", find("#plan_name").value
    assert page.has_content?("TOTAL ACTIONS")
    assert_equal "28", find(".action-count-circle span").text
    assert_selector("div[data-benchmark-indicator-display-abbrev='2.1']")
    assert_selector("div[data-benchmark-indicator-display-abbrev='9.1']")

    # verify nudge content for 5-year plan
    assert_selector(".nudge-container") do
      assert page.has_content?(
               "5 year plans are useful for long-term planning and budgeting but should still be prioritized and realistic",
             )
    end

    # verify bar chart by technical area filter functionality
    find("line[data-original-title*=\"Surveillance\"]").click
    assert_no_selector("div[data-benchmark-indicator-display-abbrev='2.1']")
    assert_selector("div[data-benchmark-indicator-display-abbrev='9.1']")

    # un-filter to show all
    find(".action-count-circle").click
    assert_selector("div[data-benchmark-indicator-display-abbrev='2.1']")
    assert_selector("div[data-benchmark-indicator-display-abbrev='9.1']")

    find("#plan_name").fill_in with: "Saved Nigeria Plan by Areas 789"
    find("input[type=submit]").trigger(:click)

    ##
    # wind up on sign-in page and go to create an account
    assert_current_path("/users/sign_in")
    click_link("Create an account")

    ##
    # wind up on create account page
    assert_current_path("/users/sign_up")
    sleep 0.1
    find("#user_email").fill_in with: "email@example.com"
    find("#user_password").fill_in with: "123123"
    find("#user_password_confirmation").fill_in with: "123123"
    find("#new_user input[type=submit]").trigger(:click)

    assert_current_path("/plans")
    assert page.has_content?("Welcome! You have signed up successfully.")
    assert page.has_content?("Saved Nigeria Plan by Areas 789") # ugh without this form field(s) dont get filled
  end

  ##
  # usage: select_from_chosen('Option', from: 'id_of_field')
  #   example, Get Started form: select_from_chosen('Armenia', from: 'get_started_form_country_id')
  def select_from_chosen(item_text, options)
    field = find_field(options[:from], visible: false)
    find("##{field[:id]}_chosen").click
    find("##{field[:id]}_chosen ul.chosen-results li", text: item_text).click
  end
end
