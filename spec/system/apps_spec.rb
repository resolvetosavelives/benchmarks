require(File.expand_path("./test/application_system_test_case"))
class AppsTest < ApplicationSystemTestCase
  it("happy path for Nigeria JEE 1.0") do
    visit(root_url)
    click_on("Get Started") until (current_path == "/get-started")
    expect(page.has_content?("LET'S GET STARTED")).to(eq(true))
    select_from_chosen("Nigeria", from: "get_started_form_country_id")
    click_on("Next")
    choose("Joint External Evaluation (JEE)")
    choose("1 year plan")
    click_on("Next")
    assert_current_path("/plan/goals/Nigeria/jee1/1-year")
    expect(page.has_content?("JEE SCORES")).to(eq(true))
    expect(
      page.has_content?(
        "P.1.1 Legislation, laws, regulations, administrative requirements, policies or other government instruments in place are sufficient for implementation of IHR (2005)"
      )
    ).to(eq(true))
    expect(
      page.has_content?(
        "RE.2 Enabling environment in place for management of radiation emergencies"
      )
    ).to(eq(true))
    expect(find("#plan_indicators_jee1_ind_p11").value).to(eq("1"))
    expect(find("#plan_indicators_jee1_ind_p11_goal").value).to(eq("2"))
    find("#new_plan input[type=submit]").trigger(:click)
    assert_current_path(%r{^\/plans\/\d+$})
    expect(find("#plan_name").value).to(eq("Nigeria draft plan"))
    expect(find(".action-count-component .label").text).to(eq("Actions"))
    expect(find(".action-count-component .count").text).to(eq("407"))
    assert_selector("#technical-area-1")
    assert_selector("#technical-area-3")
    assert_selector(".nudge-container") do
      expect(
        page.has_content?(
          "Focus on no more than 2-3 actions per technical area"
        )
      ).to(eq(true))
    end
    find(
      "line[data-original-title*=\"Antimicrobial Resistance\"]",
      match: :first
    ).click
    assert_selector("#technical-area-3")
    assert_no_selector("#technical-area-1")
    find(".clear-filters-component a").click
    assert_selector("#technical-area-1")
    assert_selector("#technical-area-18")
    find("#plan_name").fill_in(with: "Saved Nigeria Plan 789")
    find("input[type=submit]").trigger(:click)
    assert_current_path("/users/sign_in")
    click_link("Create an account")
    assert_current_path("/users/sign_up")
    sleep(0.1)
    find("#user_email").fill_in(with: "email@example.com")
    find("#user_password").fill_in(with: "123123")
    find("#user_password_confirmation").fill_in(with: "123123")
    find("#new_user input[type=submit]").trigger(:click)
    assert_current_path("/plans")
    expect(page.has_content?("Welcome! You have signed up successfully.")).to(
      eq(true)
    )
    expect(page.has_content?("Saved Nigeria Plan 789")).to(eq(true))
  end
  it("happy path for Nigeria JEE 1.0 with influenza, cholera, and ebola") do
    visit(root_url)
    click_on("Get Started") until (current_path == "/get-started")
    expect(page.has_content?("LET'S GET STARTED")).to(eq(true))
    select_from_chosen("Nigeria", from: "get_started_form_country_id")
    click_on("Next")
    choose("Joint External Evaluation (JEE)")
    choose("1 year plan")
    check("Optional: Influenza planning")
    check("Optional: Cholera planning")
    check("Optional: Ebola planning")
    click_on("Next")
    assert_current_path("/plan/goals/Nigeria/jee1/1-year?diseases=1-2-3")
    expect(page.has_content?("JEE SCORES")).to(eq(true))
    expect(
      page.has_content?(
        "P.1.1 Legislation, laws, regulations, administrative requirements, policies or other government instruments in place are sufficient for implementation of IHR (2005)"
      )
    ).to(eq(true))
    expect(
      page.has_content?(
        "RE.2 Enabling environment in place for management of radiation emergencies"
      )
    ).to(eq(true))
    expect(find("#plan_indicators_jee1_ind_p11").value).to(eq("1"))
    expect(find("#plan_indicators_jee1_ind_p11_goal").value).to(eq("2"))
    find("#new_plan input[type=submit]").trigger(:click)
    assert_current_path(%r{^\/plans\/\d+$})
    expect(find("#plan_name").value).to(eq("Nigeria draft plan"))
    expect(find(".action-count-component .label").text).to(eq("Actions"))
    expect(find(".action-count-component .count").text).to(eq("407"))
    assert_selector("#technical-area-1")
    assert_selector("#technical-area-3")
    assert_selector(".nudge-container") do
      expect(
        page.has_content?(
          "Focus on no more than 2-3 actions per technical area"
        )
      ).to(eq(true))
    end
    indicators_no_capacity_gap = all(".benchmark-container .no-capacity-gap")
    indicator_headings =
      indicators_no_capacity_gap.map do |indicator|
        indicator.ancestor(".benchmark-container").find(".header").text
      end
    expect(
      [
        "Benchmark 1.2: Financing is available for the implementation of IHR capacities",
        "Benchmark 1.3: Financing available for timely response to public health emergencies",
        "Benchmark 3.1: Effective multisectoral coordination on AMR",
        "Benchmark 10.3: In-service trainings are available",
        "Benchmark 12.1: Functional emergency response coordination is in place"
      ]
    ).to(eq(indicator_headings))
    add_actions =
      indicators_no_capacity_gap.map do |indicator|
        indicator.ancestor(".benchmark-container").find(".action-form")
      end
    expect((add_actions.count == indicators_no_capacity_gap.count)).to(
      be_truthy
    )
    find(".tab-content .ct-legend").has_content?("Influenza")
    find(".tab-content .ct-legend").has_content?("Cholera")
    find(".tab-content .ct-legend").has_content?("Ebola")
    all("#tabContentForTechnicalArea .ct-series-a .ct-bar")[1].click
    count_bars = all("#tabContentForTechnicalArea .ct-series-a .ct-bar").count
    count_deselected =
      all("#tabContentForTechnicalArea .ct-series-a .ct-bar.ct-deselected")
        .count
    expect((count_deselected == (count_bars - 1))).to(be_truthy)
    dropdown_toggle = find("#dropdown-filter-technical-area .dropdown-toggle")
    expect(dropdown_toggle.text).to(eq("IHR coordination"))
    find(".clear-filters-component a").click
    count_deselected =
      all("#tabContentForTechnicalArea .ct-series-a .ct-bar.ct-deselected")
        .count
    expect((count_deselected == 0)).to(be_truthy)
    dropdown_toggle = find("#dropdown-filter-technical-area .dropdown-toggle")
    expect(dropdown_toggle.text).to(eq("All"))
    find("#tabForActionType").click
    find(".tab-content .ct-legend").has_content?("Influenza")
    find(".tab-content .ct-legend").has_content?("Cholera")
    find(".tab-content .ct-legend").has_content?("Ebola")
    all("#tabContentForActionType .ct-series-b .ct-bar")[1].click
    count_bars = all("#tabContentForActionType .ct-series-b .ct-bar").count
    count_deselected =
      all("#tabContentForActionType .ct-series-b .ct-bar.ct-deselected").count
    expect((count_deselected == (count_bars - 1))).to(be_truthy)
    dropdown_toggle = find("#dropdown-filter-action-type .dropdown-toggle")
    expect(dropdown_toggle.text).to(eq("Assessment and Data Use"))
    tooltip = find(".tooltip.show")
    expect(tooltip.text).to(match("Assessment and Data Use: 53"))
    expect(tooltip.text).to(match("Health System: 40"))
    expect(tooltip.text).to(match("Influenza-specific: 8"))
    expect(tooltip.text).to(match("Cholera-specific: 5"))
    find("#dropdown-filter-action-type").click
    find("a", text: "All").click
    count_deselected =
      all("#tabContentForActionType .ct-series-b .ct-bar.ct-deselected").count
    expect((count_deselected == 0)).to(be_truthy)
    find("#tabForTechnicalArea").click
    assert_selector("#technical-area-1") do
      expect(
        page.has_content?(
          "government instruments relevant to pandemic influenza"
        )
      ).to(eq(true))
    end
    find(
      "line[data-original-title*=\"Antimicrobial Resistance\"]",
      match: :first
    ).click
    assert_selector("#technical-area-3")
    assert_no_selector("#technical-area-1")
    find(".clear-filters-component a").click
    assert_selector("#technical-area-1")
    assert_selector("#technical-area-18")
    find("#plan_name").fill_in(with: "Saved Nigeria Plan 789")
    find("input[type=submit]").trigger(:click)
    assert_current_path("/users/sign_in")
    click_link("Create an account")
    assert_current_path("/users/sign_up")
    sleep(0.1)
    find("#user_email").fill_in(with: "email@example.com")
    find("#user_password").fill_in(with: "123123")
    find("#user_password_confirmation").fill_in(with: "123123")
    find("#new_user input[type=submit]").trigger(:click)
    assert_current_path("/plans")
    expect(page.has_content?("Welcome! You have signed up successfully.")).to(
      eq(true)
    )
    expect(page.has_content?("Saved Nigeria Plan 789")).to(eq(true))
    click_on("WHO BENCHMARKS")
    expect(page.has_content?("BENCHMARKS FOR IHR CAPACITIES")).to(eq(true))
    click_on("REFERENCE LIBRARY")
    expect(
      page.has_content?(
        "Establishment of a Sentinel Laboratory-Based Antimicrobial Resistance Surveillance Network in Ethiopia"
      )
    ).to(eq(true))
    click_on("email@example.com")
    click_on("My Plans")
    expect(page.has_content?("Saved Nigeria Plan 789")).to(eq(true))
    sleep(0.2)
    click_on("Saved Nigeria Plan 789")
    sleep(0.2)
    expect(page.has_content?("National Legislation, Policy and Financing")).to(
      eq(true)
    )
    click_on("email@example.com")
    click_on("My Plans")
    expect(page.has_content?("Saved Nigeria Plan 789")).to(eq(true))
    click_link("Delete")
    expect(page.has_content?("You haven't started any plans yet")).to(eq(true))
  end
  it("happy path for Armenia SPAR 2018 5-year plan") do
    visit(root_url)
    click_on("Get Started") until (current_path == "/get-started")
    expect(page.has_content?("LET'S GET STARTED")).to(eq(true))
    select_from_chosen("Armenia", from: "get_started_form_country_id")
    click_on("Next")
    choose("State Party Annual Report (SPAR)")
    choose("5 year plan")
    click_on("Next")
    assert_current_path("/plan/goals/Armenia/spar_2018/5-year")
    expect(page.has_content?("SPAR SCORES")).to(eq(true))
    expect(
      page.has_content?(
        "C4.1 Multisectoral collaboration mechanism for food safety events"
      )
    ).to(eq(true))
    expect(find("#plan_indicators_spar_2018_ind_c41").value).to(eq("2"))
    expect(find("#plan_indicators_spar_2018_ind_c41_goal").value).to(eq("4"))
    find("#new_plan input[type=submit]").trigger(:click)
    assert_current_path(%r{^\/plans\/\d+$})
    expect(find("#plan_name").value).to(eq("Armenia draft plan"))
    expect(find(".action-count-component .label").text).to(eq("Actions"))
    expect(find(".action-count-component .count").text).to(eq("279"))
    expect(
      page.has_content?(
        "Document and disseminate information on the timely distribution and effective use of funds to increase health security (such as preventing or stopping the spread of disease), at the national and subnational levels in all relevant ministries or sectors."
      )
    ).to(eq(true))
    find("#plan_name").fill_in(with: "Saved Armenia Plan")
    find("input[type=submit]").trigger(:click)
    assert_current_path("/users/sign_in")
    click_link("Create an account")
    assert_current_path("/users/sign_up")
    sleep(0.1)
    find("#user_email").fill_in(with: "email@example.com")
    find("#user_password").fill_in(with: "123123")
    find("#user_password_confirmation").fill_in(with: "123123")
    find("#new_user input[type=submit]").trigger(:click)
    assert_current_path("/plans")
    expect(page.has_content?("Welcome! You have signed up successfully.")).to(
      eq(true)
    )
    expect(page.has_content?("Saved Armenia Plan")).to(eq(true))
  end
  it("happy path for Nigeria JEE 1.0 plan by technical areas 5-year") do
    visit(root_url)
    click_on("Get Started") until (current_path == "/get-started")
    expect(page.has_content?("LET'S GET STARTED")).to(eq(true))
    select_from_chosen("Nigeria", from: "get_started_form_country_id")
    click_on("Next")
    choose("Joint External Evaluation (JEE)")
    check("Optional: Plan by technical area(s)")
    sleep(0.1)
    check("IHR coordination, communication and advocacy")
    check("Surveillance")
    sleep(0.2)
    choose("5 year plan")
    click_on("Next")
    assert_current_path("/plan/goals/Nigeria/jee1/5-year?areas=2-9")
    expect(page.has_content?("JEE SCORES")).to(eq(true))
    expect(
      page.has_content?(
        "P.2.1 A functional mechanism is established for the coordination and integration of relevant sectors in the implementation of IHR"
      )
    ).to(eq(true))
    expect(
      page.has_content?("D.2.1 Indicator- and event-based surveillance systems")
    ).to(eq(true))
    expect(find("#plan_indicators_jee1_ind_p21").value).to(eq("2"))
    expect(find("#plan_indicators_jee1_ind_p21_goal").value).to(eq("4"))
    find("#new_plan input[type=submit]").trigger(:click)
    assert_current_path(%r{^\/plans\/\d+$})
    expect(find("#plan_name").value).to(eq("Nigeria draft plan"))
    expect(find(".action-count-component .label").text).to(eq("Actions"))
    expect(find(".action-count-component .count").text).to(eq("200"))
    assert_selector("div[data-benchmark-indicator-display-abbrev='2.1']")
    assert_selector("div[data-benchmark-indicator-display-abbrev='9.1']")
    assert_selector(".nudge-container") do
      expect(
        page.has_content?(
          "5 year plans are useful for long-term planning and budgeting but should still be prioritized and realistic"
        )
      ).to(eq(true))
    end
    find("line[data-original-title*=\"Surveillance\"]", match: :first).click
    assert_no_selector("div[data-benchmark-indicator-display-abbrev='2.1']")
    assert_selector("div[data-benchmark-indicator-display-abbrev='9.1']")
    find(".clear-filters-component a").click
    assert_selector("div[data-benchmark-indicator-display-abbrev='2.1']")
    assert_selector("div[data-benchmark-indicator-display-abbrev='9.1']")
    find("#plan_name").fill_in(with: "Saved Nigeria Plan by Areas 789")
    find("input[type=submit]").trigger(:click)
    assert_current_path("/users/sign_in")
    click_link("Create an account")
    assert_current_path("/users/sign_up")
    sleep(0.1)
    find("#user_email").fill_in(with: "email@example.com")
    find("#user_password").fill_in(with: "123123")
    find("#user_password_confirmation").fill_in(with: "123123")
    find("#new_user input[type=submit]").trigger(:click)
    assert_current_path("/plans")
    expect(page.has_content?("Welcome! You have signed up successfully.")).to(
      eq(true)
    )
    expect(page.has_content?("Saved Nigeria Plan by Areas 789")).to(eq(true))
  end
end
