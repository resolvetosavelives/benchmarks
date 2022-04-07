require "system_helper"

RSpec.describe "Happy Path", type: :system, js: true do
  scenario "happy path for Nigeria JEE 1.0" do
    puts "Running happy path for Nigeria JEE 1.0"
    retry_on_pending_connection { visit(root_path) }

    click_on("Get Started", match: :first) until current_path == "/get-started"
    expect(page).to have_content("LET'S GET STARTED")
    select_from_chosen "Nigeria", from: "get_started_form_country_id"
    click_on "Next"

    choose "Joint External Evaluation (JEE)"
    choose "1-year plan"
    click_on "Next"

    ##
    # turn up on the Goal-setting page for the selected options and hit save
    expect(page).to have_current_path("/plan/goals/Nigeria/jee1/1-year")
    expect(page).to have_content("JEE SCORES")

    expect(page).to have_content(
      "P.1.1 Legislation, laws, regulations, administrative requirements, policies or other government instruments in place are sufficient for implementation of IHR (2005)"
    )
    expect(page).to have_content(
      "RE.2 Enabling environment in place for management of radiation emergencies"
    )
    expect(find("#plan_indicators_jee1_ind_p11").value).to eq("1")
    expect(find("#plan_indicators_jee1_ind_p11_goal").value).to eq("2")
    find("#new_plan input[type=submit]").trigger(:click)

    ##
    # wind up on the View Plan page after the plan has been saved, and then make an edit
    expect(page).to have_current_path(%r{^\/plans\/\d+$})
    expect(find("#plan_name").value).to eq("Nigeria draft plan")
    expect(find(".action-count-component .label").text).to eq("Actions")
    expect(find(".action-count-component .count").text).to eq("219")
    expect(page).to have_selector("#technical-area-1")
    expect(page).to have_selector("#technical-area-3")

    # nudge content for 1-year plan
    expect(find(".nudge-container")).to have_content(
      "Focus on no more than 2-3 actions per technical area"
    )

    ##
    # save the state_from_server to file, for use in jest tests.
    # uncomment and run this to update the JSON data file periodically or upon STATE_FROM_SERVER structure/format change.
    # save_state_from_server(page)

    # verify bar chart by technical area filter functionality
    find(
      "line[data-original-title*=\"Antimicrobial Resistance\"]",
      match: :first
    ).click
    expect(page).to have_selector("#technical-area-3") # the last one
    expect(page).not_to have_selector("#technical-area-1") # the first one

    # un-filter to show all
    find(".clear-filters-component a").click
    expect(page).to have_selector("#technical-area-1")
    expect(page).to have_selector("#technical-area-18")

    # edit the plan name and hit save button
    find("#plan_name").fill_in(with: "Saved Nigeria Plan 789")
    find("input[type=submit]").trigger(:click)

    ##
    # wind up on sign-in page and go to create an account
    expect(page).to have_current_path("/users/sign_in")
    click_link "Create an account"

    ##
    # wind up on create account page
    expect(page).to have_current_path("/users/sign_up")
    sleep 0.1
    find("#user_email").fill_in(with: "email@example.com")
    find("#user_password").fill_in(with: "123123")
    find("#user_password_confirmation").fill_in(with: "123123")
    find("#new_user input[type=submit]").trigger(:click)

    ##
    # wind up on create account page
    expect(page).to have_current_path("/plans")
    expect(page).to have_content("Welcome! You have signed up successfully.")
    expect(page).to have_content("Saved Nigeria Plan 789")
  end

  scenario "happy path for Nigeria JEE 1.0 with influenza, cholera, and ebola" do
    puts "Running happy path for Nigeria JEE 1.0 with influenza, cholera, and ebola"
    retry_on_pending_connection { visit(root_path) }
    click_on("Get Started", match: :first) until current_path == "/get-started"
    expect(page).to have_content("LET'S GET STARTED")
    select_from_chosen("Nigeria", from: "get_started_form_country_id")
    click_on "Next"
    choose "Joint External Evaluation (JEE)"
    choose "1-year plan"
    check "Influenza planning"
    check "Cholera planning"
    check "Ebola planning"
    click_on "Next"

    ##
    # turn up on the Goal-setting page for the selected options and hit save
    expect(page).to have_current_path(
      "/plan/goals/Nigeria/jee1/1-year?diseases=1-2-3"
    )
    expect(page).to have_content("JEE SCORES")
    expect(page).to have_content(
      "P.1.1 Legislation, laws, regulations, administrative requirements, policies or other government instruments in place are sufficient for implementation of IHR (2005)"
    )
    expect(page).to have_content(
      "RE.2 Enabling environment in place for management of radiation emergencies"
    )
    expect(find("#plan_indicators_jee1_ind_p11").value).to eq("1")
    expect(find("#plan_indicators_jee1_ind_p11_goal").value).to eq("2")
    find("#new_plan input[type=submit]").trigger(:click)

    ##
    # wind up on the View Plan page after the plan has been saved, and then make an edit
    expect(page).to have_current_path(%r{^\/plans\/\d+$})
    expect(find("#plan_name").value).to eq("Nigeria draft plan")
    expect(find(".action-count-component .label").text).to eq("Actions")
    expect(find(".action-count-component .count").text).to eq("391")
    expect(page).to have_selector("#technical-area-1")
    expect(page).to have_selector("#technical-area-3")

    expect(find(".nudge-container")).to have_content(
      "Focus on no more than 2-3 actions per technical area"
    )

    ##
    # Make sure there are the correct number of indicators with no capacity gap
    indicators_no_capacity_gap = all(".benchmark-container .no-capacity-gap")
    indicator_headings =
      indicators_no_capacity_gap.map do |indicator|
        indicator.ancestor(".benchmark-container").find(".header").text
      end
    expect(indicator_headings).to eq(
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

    expect(add_actions.count).to eq(indicators_no_capacity_gap.count)

    ##
    # make sure Technical Area tab has a legend
    legend = find(".tab-content .ct-legend")
    expect(legend).to have_content("Influenza")
    expect(legend).to have_content("Cholera")
    expect(legend).to have_content("Ebola")

    ##
    # click on one of the bars and make sure others are deselected
    all("#tabContentForTechnicalArea .ct-series-a .ct-bar")[1].click
    count_bars = all("#tabContentForTechnicalArea .ct-series-a .ct-bar").count
    count_deselected =
      all("#tabContentForTechnicalArea .ct-series-a .ct-bar.ct-deselected")
        .count
    expect(count_deselected).to eq(count_bars - 1)

    # make sure the filter dropdown has the correct value
    dropdown_toggle = find("#dropdown-filter-technical-area .dropdown-toggle")
    expect(dropdown_toggle.text).to eq("IHR coordination")

    ##
    # reset and make sure no bar are deselected
    find(".clear-filters-component a").click
    count_deselected =
      all("#tabContentForTechnicalArea .ct-series-a .ct-bar.ct-deselected")
        .count
    expect(count_deselected).to eq(0)
    dropdown_toggle = find("#dropdown-filter-technical-area .dropdown-toggle")
    expect(dropdown_toggle.text).to eq("All")

    # make sure the filter dropdown has the correct value
    find("#tabForActionType").click
    legend = find(".tab-content .ct-legend")
    expect(legend).to have_content("Influenza")
    expect(legend).to have_content("Cholera")
    expect(legend).to have_content("Ebola")

    ##
    # click on one of the bars and make sure others are deselected
    all("#tabContentForActionType .ct-series-b .ct-bar")[1].click
    count_bars = all("#tabContentForActionType .ct-series-b .ct-bar").count
    count_deselected =
      all("#tabContentForActionType .ct-series-b .ct-bar.ct-deselected").count
    expect(count_deselected).to eq(count_bars - 1)

    # make sure the filter dropdown has the correct value
    dropdown_toggle = find("#dropdown-filter-action-type .dropdown-toggle")
    expect(dropdown_toggle.text).to eq("Assessment and Data Use")
    tooltip = find(".tooltip.show")
    expect(tooltip.text).to match("Assessment and Data Use: 52")
    expect(tooltip.text).to match("Health System: 39")
    expect(tooltip.text).to match("Influenza-specific: 8")
    expect(tooltip.text).to match("Cholera-specific: 5")
    expect(tooltip.text).to match("Ebola-specific: 11")

    ##
    # click on 'All' in the dropdown toggle
    find("#dropdown-filter-action-type").click
    find("a", text: "All").click
    count_deselected =
      all("#tabContentForActionType .ct-series-b .ct-bar.ct-deselected").count
    expect(count_deselected).to eq(0)

    ##
    # go back to technical area tab
    find("#tabForTechnicalArea").click
    expect(find("#technical-area-1")).to have_content(
      "government instruments relevant to pandemic influenza"
    )

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
    expect(page).to have_selector("#technical-area-3") # the last one
    expect(page).not_to have_selector("#technical-area-1") # the first one

    # un-filter to show all
    find(".clear-filters-component a").click
    expect(page).to have_selector("#technical-area-1")
    expect(page).to have_selector("#technical-area-18")

    # edit the plan name and hit save button
    find("#plan_name").fill_in(with: "Saved Nigeria Plan 789")
    find("input[type=submit]").trigger(:click)

    ##
    # wind up on sign-in page and go to create an account
    expect(page).to have_current_path("/users/sign_in")
    click_link "Create an account"

    ##
    # wind up on create account page
    expect(page).to have_current_path("/users/sign_up")
    sleep 0.1
    find("#user_email").fill_in(with: "email@example.com")
    find("#user_password").fill_in(with: "123123")
    find("#user_password_confirmation").fill_in(with: "123123")
    find("#new_user input[type=submit]").trigger(:click)

    ##
    # make sure the plan was saved
    expect(page).to have_current_path("/plans")
    expect(page).to have_content("Welcome! You have signed up successfully.")
    expect(page).to have_content("Saved Nigeria Plan 789")

    ##
    # make sure Turbolinks and the dropdown menu are working in both react and non-react contexts
    click_on "WHO BENCHMARKS"
    expect(page).to have_content("BENCHMARKS FOR IHR CAPACITIES")
    click_on "REFERENCE LIBRARY"
    expect(page).to have_content(
      "Tackling Antimicrobial Resistance (AMR) Together: Working Paper 1.0 Multisectoral coordination"
    )
    click_on "email@example.com"
    click_on "My Plans"
    expect(page).to have_content("Saved Nigeria Plan 789")
    sleep 0.2
    click_on "Saved Nigeria Plan 789"

    retry_on_pending_connection do
      expect(page).to have_selector(
        "h3",
        text: "National Legislation, Policy and Financing"
      )
    end

    click_on "email@example.com"
    click_on "My Plans"
    expect(page).to have_content("Saved Nigeria Plan 789")

    ##
    # delete the plan
    accept_prompt { click_link "Delete" }
    expect(page).to have_content("You haven't started any plans yet")
  end

  scenario "happy path for Armenia SPAR 2018 5-year plan" do
    puts "Armenia SPAR 2018 5-year plan"
    retry_on_pending_connection { visit root_path }
    click_on("Get Started", match: :first) until current_path == "/get-started"
    expect(page).to have_content("LET'S GET STARTED")
    select_from_chosen("Armenia", from: "get_started_form_country_id")
    click_on "Next"
    choose "State Party Self-Assessment Annual Report (SPAR)"
    choose "5-year plan"
    click_on "Next"

    ##
    # turn up on the plan goal-setting page
    expect(page).to have_current_path("/plan/goals/Armenia/spar_2018/5-year")
    expect(page).to have_content("SPAR SCORES")
    expect(page).to have_content(
      "C4.1 Multisectoral collaboration mechanism for food safety events"
    )

    # verify that the 5-year plan has set goal from 2 to 4
    expect(find("#plan_indicators_spar_2018_ind_c41").value).to eq("2")
    expect(find("#plan_indicators_spar_2018_ind_c41_goal").value).to eq("4")
    find("#new_plan input[type=submit]").trigger(:click)

    ##
    # wind up on the View Plan page, make an edit, and save the plan
    expect(page).to have_current_path(%r{^\/plans\/\d+$})
    expect(find("#plan_name").value).to eq("Armenia draft plan")
    expect(find(".action-count-component .label").text).to eq("Actions")

    # action count was 103 but became 98 along with refactoring changes, I think due to bug(s) fixed
    expect(find(".action-count-component .count").text).to eq("102")
    expect(page).to have_content(
      "Document and disseminate information on the timely distribution and effective use of funds to increase health security (such as preventing or stopping the spread of disease), at the national and subnational levels in all relevant ministries or sectors."
    )
    find("#plan_name").fill_in(with: "Saved Armenia Plan")
    find("input[type=submit]").trigger(:click)

    ##
    # wind up on the Sign In page, go to Create an Account
    expect(page).to have_current_path("/users/sign_in")
    click_link "Create an account"

    ##
    # at the Create an Account page, fill and submit the form
    expect(page).to have_current_path("/users/sign_up")
    sleep 0.1
    find("#user_email").fill_in(with: "email@example.com")
    find("#user_password").fill_in(with: "123123")
    find("#user_password_confirmation").fill_in(with: "123123")
    find("#new_user input[type=submit]").trigger(:click)

    ##
    # wind up on the View Plan page, make an edit, and save the plan
    expect(page).to have_current_path("/plans")
    expect(page).to have_content("Welcome! You have signed up successfully.")
    expect(page).to have_content("Saved Armenia Plan")
  end

  scenario "happy path for Nigeria JEE 1.0 plan by technical areas 5-year" do
    puts "Nigeria JEE 1.0 plan by technical areas 5-year"
    retry_on_pending_connection { visit root_path }
    click_on("Get Started", match: :first) until current_path == "/get-started"
    expect(page).to have_content("LET'S GET STARTED")
    select_from_chosen "Nigeria", from: "get_started_form_country_id"
    click_on "Next"
    choose "Joint External Evaluation (JEE)" #   fails form validation. extra weird because that same flow works in the other test cases.
    check "Optional: Plan by technical area(s)"
    sleep 0.1
    check "IHR coordination, communication and advocacy"
    check "Surveillance"
    sleep 0.2
    choose "5-year plan"
    click_on "Next"

    ##
    # turn up on the plan goal-setting page
    expect(page).to have_current_path(
      "/plan/goals/Nigeria/jee1/5-year?areas=2-9"
    )
    expect(page).to have_content("JEE SCORES")
    expect(page).to have_content(
      "P.2.1 A functional mechanism is established for the coordination and integration of relevant sectors in the implementation of IHR"
    )
    expect(page).to have_content(
      "D.2.1 Indicator- and event-based surveillance systems"
    )
    expect(find("#plan_indicators_jee1_ind_p21").value).to eq("2")

    # verify that this 5-year plan has goal set to 4 instead of 3
    expect(find("#plan_indicators_jee1_ind_p21_goal").value).to eq("4")
    find("#new_plan input[type=submit]").trigger(:click)

    ##
    # turn up on the View Plan, make an edit, save the plan
    expect(page).to have_current_path(%r{^\/plans\/\d+$})
    expect(find("#plan_name").value).to eq("Nigeria draft plan")
    expect(find(".action-count-component .label").text).to eq("Actions")
    expect(find(".action-count-component .count").text).to eq("28")
    expect(page).to have_selector(
      "div[data-benchmark-indicator-display-abbrev='2.1']"
    )
    expect(page).to have_selector(
      "div[data-benchmark-indicator-display-abbrev='9.1']"
    )

    # verify nudge content for 5-year plan
    expect(find(".nudge-container")).to have_content(
      "5-year plans are useful for long-term planning and budgeting but should still be prioritized and realistic"
    )

    # verify bar chart by technical area filter functionality
    find("line[data-original-title*=\"Surveillance\"]", match: :first).click
    expect(page).not_to have_selector(
      "div[data-benchmark-indicator-display-abbrev='2.1']"
    )
    expect(page).to have_selector(
      "div[data-benchmark-indicator-display-abbrev='9.1']"
    )

    # un-filter to show all
    find(".clear-filters-component a").click
    expect(page).to have_selector(
      "div[data-benchmark-indicator-display-abbrev='2.1']"
    )
    expect(page).to have_selector(
      "div[data-benchmark-indicator-display-abbrev='9.1']"
    )

    find("#plan_name").fill_in(with: "Saved Nigeria Plan by Areas 789")
    find("input[type=submit]").trigger(:click)

    ##
    # wind up on sign-in page and go to create an account
    expect(page).to have_current_path("/users/sign_in")
    click_link "Create an account"

    ##
    # wind up on create account page
    expect(page).to have_current_path("/users/sign_up")
    sleep 0.1
    email = "email@example.com"
    find("#user_email").fill_in(with: email)
    find("#user_password").fill_in(with: "123123")
    find("#user_password_confirmation").fill_in(with: "123123")
    find("#new_user input[type=submit]").trigger(:click)

    expect(page).to have_current_path("/plans")
    expect(page).to have_content("Welcome! You have signed up successfully.")
    expect(page).to have_content("Saved Nigeria Plan by Areas 789") # ugh without this form field(s) dont get filled

    ##
    # verify that logout works
    click_on email
    click_on "Log Out"
    expect(page).to have_current_path("/")
    expect(page).to have_content("LOG IN")
  end
end
