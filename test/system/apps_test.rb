require File.expand_path("./test/application_system_test_case")

class AppsTest < ApplicationSystemTestCase
  test "happy path for Nigeria JEE 1.0" do
    visit root_url
    click_on("Get Started") until current_path == "/get-started"
    assert page.has_content?("LET'S GET STARTED")
    select_from_chosen("Nigeria", from: "get_started_form_country_id")
    click_on("Next")

    choose "Joint External Evaluation (JEE)"
    choose "1 year plan"
    click_on("Next")

    ##
    # turn up on the Goal-setting page for the selected options and hit save
    assert_current_path("/plan/goals/Nigeria/jee1/1-year")
    assert page.has_content?("JEE SCORES")
    assert page.has_content?(
             "P.1.1 Legislation, laws, regulations, administrative requirements, policies or other government instruments in place are sufficient for implementation of IHR (2005)"
           )
    assert page.has_content?(
             "RE.2 Enabling environment in place for management of radiation emergencies"
           )
    assert_equal "1", find("#plan_indicators_jee1_ind_p11").value
    assert_equal "2", find("#plan_indicators_jee1_ind_p11_goal").value
    find("#new_plan input[type=submit]").trigger(:click)

    ##
    # wind up on the View Plan page after the plan has been saved, and then make an edit
    assert_current_path(%r{^\/plans\/\d+$})
    assert_equal "Nigeria draft plan", find("#plan_name").value
    assert_equal "Actions", find(".action-count-component .label").text
    assert_equal "407", find(".action-count-component .count").text
    assert_selector("#technical-area-1") # the first one
    assert_selector("#technical-area-3") # the last one
    assert_selector(".nudge-container") do
      assert page.has_content?(
               # nudge content for 1-year plan
               "Focus on no more than 2-3 actions per technical area"
             )
    end

    ##
    # save the state_from_server to file, for use in jest tests.
    # uncomment and run this to update the JSON data file periodically or upon STATE_FROM_SERVER structure/format change.
    # save_state_from_server(page)

    # verify bar chart by technical area filter functionality
    find(
      "line[data-original-title*=\"Antimicrobial Resistance\"]",
      match: :first
    ).click
    assert_selector("#technical-area-3") # the last one
    assert_no_selector("#technical-area-1") # the first one

    # un-filter to show all
    find(".clear-filters-component a").click
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

  test "happy path for Nigeria JEE 1.0 with influenza, cholera, and ebola" do
    ##
    # visit home page
    visit root_url
    click_on("Get Started") until current_path == "/get-started"
    assert page.has_content?("LET'S GET STARTED")

    select_from_chosen("Nigeria", from: "get_started_form_country_id")
    click_on("Next")
    choose "Joint External Evaluation (JEE)"
    choose "1 year plan"
    check "Optional: Influenza planning"
    check "Optional: Cholera planning"
    check "Optional: Ebola planning"
    click_on("Next")

    ##
    # turn up on the Goal-setting page for the selected options and hit save
    assert_current_path("/plan/goals/Nigeria/jee1/1-year?diseases=1-2-3")
    assert page.has_content?("JEE SCORES")
    assert page.has_content?(
             "P.1.1 Legislation, laws, regulations, administrative requirements, policies or other government instruments in place are sufficient for implementation of IHR (2005)"
           )
    assert page.has_content?(
             "RE.2 Enabling environment in place for management of radiation emergencies"
           )
    assert_equal "1", find("#plan_indicators_jee1_ind_p11").value
    assert_equal "2", find("#plan_indicators_jee1_ind_p11_goal").value
    find("#new_plan input[type=submit]").trigger(:click)

    ##
    # wind up on the View Plan page after the plan has been saved, and then make an edit
    assert_current_path(%r{^\/plans\/\d+$})
    assert_equal "Nigeria draft plan", find("#plan_name").value
    assert_equal "Actions", find(".action-count-component .label").text
    assert_equal "407", find(".action-count-component .count").text
    assert_selector("#technical-area-1") # the first one
    assert_selector("#technical-area-3") # the last one
    assert_selector(".nudge-container") do
      assert page.has_content?(
               # nudge content for 1-year plan
               "Focus on no more than 2-3 actions per technical area"
             )
    end

    ##
    # Make sure there are the correct number of indicators with no capacity gap
    indicators_no_capacity_gap = all(".benchmark-container .no-capacity-gap")
    indicator_headings =
      indicators_no_capacity_gap.map do |indicator|
        indicator.ancestor(".benchmark-container").find(".header").text
      end
    assert_equal(
      indicator_headings,
      [
        "Benchmark 1.2: Financing is available for the implementation of IHR capacities",
        "Benchmark 1.3: Financing available for timely response to public health emergencies",
        "Benchmark 3.1: Effective multisectoral coordination on AMR",
        "Benchmark 10.3: In-service trainings are available",
        "Benchmark 12.1: Functional emergency response coordination is in place"
      ]
    )

    # and make sure there are Add Action components for each of these indicators
    add_actions =
      indicators_no_capacity_gap.map do |indicator|
        indicator.ancestor(".benchmark-container").find(".action-form")
      end
    assert(add_actions.count == indicators_no_capacity_gap.count)

    ##
    # make sure Technical Area tab has a legend
    find(".tab-content .ct-legend").has_content?("Influenza")
    find(".tab-content .ct-legend").has_content?("Cholera")
    find(".tab-content .ct-legend").has_content?("Ebola")

    ##
    # click on one of the bars and make sure others are deselected
    all("#tabContentForTechnicalArea .ct-series-a .ct-bar")[1].click
    count_bars = all("#tabContentForTechnicalArea .ct-series-a .ct-bar").count
    count_deselected =
      all("#tabContentForTechnicalArea .ct-series-a .ct-bar.ct-deselected")
        .count
    assert(count_deselected == count_bars - 1)

    # make sure the filter dropdown has the correct value
    dropdown_toggle = find("#dropdown-filter-technical-area .dropdown-toggle")
    assert_equal "IHR coordination", dropdown_toggle.text

    ##
    # reset and make sure no bar are deselected
    find(".clear-filters-component a").click
    count_deselected =
      all("#tabContentForTechnicalArea .ct-series-a .ct-bar.ct-deselected")
        .count
    assert(count_deselected == 0)

    # make sure the filter dropdown has the correct value
    dropdown_toggle = find("#dropdown-filter-technical-area .dropdown-toggle")
    assert_equal "All", dropdown_toggle.text

    ##
    # make sure Action Type tab has a legend
    find("#tabForActionType").click
    find(".tab-content .ct-legend").has_content?("Influenza")
    find(".tab-content .ct-legend").has_content?("Cholera")
    find(".tab-content .ct-legend").has_content?("Ebola")

    ##
    # click on one of the bars and make sure others are deselected
    all("#tabContentForActionType .ct-series-b .ct-bar")[1].trigger("click")
    count_bars = all("#tabContentForActionType .ct-series-b .ct-bar").count
    count_deselected =
      all("#tabContentForActionType .ct-series-b .ct-bar.ct-deselected").count
    assert(count_deselected == count_bars - 1)

    # make sure the filter dropdown has the correct value
    dropdown_toggle = find("#dropdown-filter-action-type .dropdown-toggle")
    assert_equal "Assessment and Data Use", dropdown_toggle.text

    tooltip = find(".tooltip.show")
    assert_match "Assessment and Data Use: 64", tooltip.text
    assert_match "Health System: 51", tooltip.text
    assert_match "Influenza-specific: 8", tooltip.text
    assert_match "Cholera-specific: 5", tooltip.text

    ##
    # click on 'All' in the dropdown toggle
    find("#dropdown-filter-action-type").click
    find("a", text: "All").click
    count_deselected =
      all("#tabContentForActionType .ct-series-b .ct-bar.ct-deselected").count
    assert(count_deselected == 0)

    ##
    # go back to technical area tab
    find("#tabForTechnicalArea").click

    assert_selector("#technical-area-1") do
      assert page.has_content?(
               # nudge content for 1-year plan
               "government instruments relevant to pandemic influenza"
             )
    end

    ##
    # save the state_from_server to file, for use in jest tests.
    # uncomment and run this to update the JSON data file periodically or upon STATE_FROM_SERVER structure/format change.
    # save_state_influenza(page)
    # save_state_influenza_and_cholera(page)

    # verify bar chart by technical area filter functionality
    find(
      "line[data-original-title*=\"Antimicrobial Resistance\"]",
      match: :first
    ).click
    assert_selector("#technical-area-3") # the last one
    assert_no_selector("#technical-area-1") # the first one

    # un-filter to show all
    find(".clear-filters-component a").click
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
    # make sure the plan was saved
    assert_current_path("/plans")
    assert page.has_content?("Welcome! You have signed up successfully.")
    assert page.has_content?("Saved Nigeria Plan 789") # ugh without this form field(s) dont get filled

    ##
    # make sure Turbolinks and the dropdown menu are working in both react and non-react contexts
    click_on("WHO BENCHMARKS")
    assert page.has_content?("BENCHMARKS FOR IHR CAPACITIES")
    click_on("REFERENCE LIBRARY")
    assert page.has_content?(
             "Establishment of a Sentinel Laboratory-Based Antimicrobial Resistance Surveillance Network in Ethiopia"
           )
    click_on("email@example.com")
    click_on("My Plans")
    assert page.has_content?("Saved Nigeria Plan 789")
    sleep 0.2
    click_on("Saved Nigeria Plan 789")
    sleep 0.2
    assert page.has_content?("National Legislation, Policy and Financing")
    click_on("email@example.com")
    click_on("My Plans")
    assert page.has_content?("Saved Nigeria Plan 789")

    ##
    # delete the plan
    click_link("Delete")
    assert page.has_content?("You haven't started any plans yet")
  end

  test "happy path for Armenia SPAR 2018 5-year plan" do
    visit root_url
    click_on("Get Started") until current_path == "/get-started"
    assert page.has_content?("LET'S GET STARTED")
    select_from_chosen("Armenia", from: "get_started_form_country_id")
    click_on("Next")
    choose "State Party Annual Report (SPAR)"
    choose "5 year plan"
    click_on("Next")

    ##
    # turn up on the plan goal-setting page
    assert_current_path("/plan/goals/Armenia/spar_2018/5-year")
    assert page.has_content?("SPAR SCORES")
    assert page.has_content?(
             "C4.1 Multisectoral collaboration mechanism for food safety events"
           )

    # verify that the 5-year plan has set goal from 2 to 4
    assert_equal "2", find("#plan_indicators_spar_2018_ind_c41").value
    assert_equal "4", find("#plan_indicators_spar_2018_ind_c41_goal").value
    find("#new_plan input[type=submit]").trigger(:click)

    ##
    # wind up on the View Plan page, make an edit, and save the plan
    assert_current_path(%r{^\/plans\/\d+$})
    assert_equal "Armenia draft plan", find("#plan_name").value
    assert_equal "Actions", find(".action-count-component .label").text

    # action count was 103 but became 98 along with refactoring changes, I think due to bug(s) fixed
    assert_equal "279", find(".action-count-component .count").text
    assert page.has_content?(
             "Document and disseminate information on the timely distribution and effective use of funds to increase health security (such as preventing or stopping the spread of disease), at the national and subnational levels in all relevant ministries or sectors."
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
    visit root_url
    click_on("Get Started") until current_path == "/get-started"
    assert page.has_content?("LET'S GET STARTED")

    select_from_chosen("Nigeria", from: "get_started_form_country_id")
    click_on("Next")
    choose "Joint External Evaluation (JEE)" #   fails form validation. extra weird because that same flow works in the other test cases.
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
             "P.2.1 A functional mechanism is established for the coordination and integration of relevant sectors in the implementation of IHR"
           )
    assert page.has_content?(
             "D.2.1 Indicator- and event-based surveillance systems"
           )
    assert_equal "2", find("#plan_indicators_jee1_ind_p21").value

    # verify that this 5-year plan has goal set to 4 instead of 3
    assert_equal "4", find("#plan_indicators_jee1_ind_p21_goal").value
    find("#new_plan input[type=submit]").trigger(:click)

    ##
    # turn up on the View Plan, make an edit, save the plan
    assert_current_path(%r{^\/plans\/\d+$})
    assert_equal "Nigeria draft plan", find("#plan_name").value
    assert_equal "Actions", find(".action-count-component .label").text
    assert_equal "200", find(".action-count-component .count").text
    assert_selector("div[data-benchmark-indicator-display-abbrev='2.1']")
    assert_selector("div[data-benchmark-indicator-display-abbrev='9.1']")

    # verify nudge content for 5-year plan
    assert_selector(".nudge-container") do
      assert page.has_content?(
               "5 year plans are useful for long-term planning and budgeting but should still be prioritized and realistic"
             )
    end

    # verify bar chart by technical area filter functionality
    find("line[data-original-title*=\"Surveillance\"]", match: :first).click
    assert_no_selector("div[data-benchmark-indicator-display-abbrev='2.1']")
    assert_selector("div[data-benchmark-indicator-display-abbrev='9.1']")

    # un-filter to show all
    find(".clear-filters-component a").click
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
end
