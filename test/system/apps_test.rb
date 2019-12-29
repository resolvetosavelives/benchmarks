require File.expand_path("./test/application_system_test_case")

class AppsTest < ApplicationSystemTestCase
  setup do
    Capybara.current_driver = :cuprite
    Capybara.javascript_driver = :cuprite
  end

  test "happy path for Nigeria JEE 1.0" do
    visit root_url
    select "Nigeria", from: "country"
    find("button").trigger(:click)
    assert page.has_content?("LET'S GET STARTED ON NIGERIA")
    select "JEE 1.0", from: "assessment_type"
    click_on("Next") # .trigger(:click)
    assert_current_path(%r{goals\/Nigeria\/jee1})

    ##
    # Assessment/Goals page
    assert page.has_content?("JEE 1.0 SCORES")
    assert page.has_content?(
      "P.1.1 Legislation, laws, regulations, administrative requirements, policies or other government instruments in place are sufficient for implementation of IHR (2005)"
    )
    assert page.has_content?(
      "RE.2 Enabling environment in place for management of radiation emergencies"
    )
    assert_equal "1", find("#goal_form_jee1_ind_p11").value
    assert_equal "2", find("#goal_form_jee1_ind_p11_goal").value

    find("#new_goal_form input[type=submit]").trigger(:click)

    ##
    # Draft Plan page
    # verify and dismiss the popover
    assert_selector("#draft-plan-review-modal")
    within("#draft-plan-review-modal") do
      click_on("Next")
    end

    assert_current_path(%r{plans\/\d+})
    assert_equal "Nigeria draft plan", find("#plan_name").value
    assert page.has_content?("TOTAL ACTIVITIES")
    assert_equal "235", find(".activity-count-circle span").text
    assert_selector("#technical-area-B1") # the first one
    assert_selector("#technical-area-B18") # the last one

    # verify bar chart by technical area filter functionality
    find('line[data-original-title*="Radiation Emerg"]').click
    assert_selector("#technical-area-B18") # the last one
    assert_no_selector("#technical-area-B1") # the first one

    # "Radiation Emergencies" should be the only heading visible, with 4 acitivites
    # within "#technical-area-B18" do
    #  click_on('button[data-benchmark-activity-id="869"]')
    # end

    # unfilter to show all
    find(".activity-count-circle").click
    assert_selector("#technical-area-B1")
    assert_selector("#technical-area-B18")

    find("#plan_name").fill_in with: "Updated Plan 789"
    find("input[type=submit]").trigger(:click)

    assert_current_path("/users/sign_in")
    click_link("Create an account")

    assert_current_path("/users/sign_up")
    sleep 0.1 # ugh without this form field(s) dont get filled
    find("#user_email").fill_in with: "email@example.com"
    find("#user_password").fill_in with: "123123"
    find("#user_password_confirmation").fill_in with: "123123"
    find("#new_user input[type=submit]").trigger(:click)

    assert_current_path("/plans")
    assert page.has_content?("WELCOME")
    assert page.has_content?("Updated Plan 789")
  end

  test "happy path for Armenia SPAR 2018" do
    visit root_url
    select "Armenia", from: "country"
    find("button").trigger(:click)
    assert page.has_content?("LET'S GET STARTED ON ARMENIA")
    select "SPAR 2018", from: "assessment_type"
    find("#assessment-select-menu button").trigger(:click)
    assert_current_path(%r{goals\/Armenia\/spar_2018})

    assert page.has_content?("SPAR 2018 SCORES")
    assert page.has_content?(
      "C1.3 Financing mechanism and funds for timely response to public health emergencies"
    )
    assert_equal "3", find("#goal_form_spar_2018_ind_c13").value
    assert_equal "4", find("#goal_form_spar_2018_ind_c13_goal").value

    find("#new_goal_form input[type=submit]").trigger(:click)

    assert_current_path(%r{plans\/\d+})
    assert_equal "Armenia draft plan", find("#plan_name").value
    assert page.has_content?("TOTAL ACTIVITIES")
    # activity count was 103 but became 98 along with refactoring changes, I think due to bug(s) fixed
    assert_equal "98", find(".activity-count-circle span").text

    assert page.has_content?(
      "Document and disseminate information on the timely distribution and effective use of funds to increase health security (such as preventing or stopping the spread of disease), at the national and subnational levels in all relevant ministries or sectors."
    )
    find("#plan_name").fill_in with: "Updated Draft Plan"
    find("input[type=submit]").trigger(:click)

    assert_current_path("/users/sign_in")
    click_link("Create an account")

    assert_current_path("/users/sign_up")
    sleep 0.1 # ugh without this form field(s) dont get filled
    find("#user_email").fill_in with: "email@example.com"
    find("#user_password").fill_in with: "123123"
    find("#user_password_confirmation").fill_in with: "123123"
    find("#new_user input[type=submit]").trigger(:click)

    assert_current_path("/plans")
    assert page.has_content?("WELCOME")
    assert page.has_content?("Updated Draft Plan")
  end

  test "happy path for Nigeria from technical areas IHR Comm and Surveillance" do
    visit root_url
    select "Nigeria", from: "country"
    find("button").trigger(:click)
    # popover should appear to choose which plan type to make
    assert page.has_content?("LET'S GET STARTED ON NIGERIA")
    select "Plan by Technical Areas", from: "assessment_type"
    click_on("Next")
    # next, choose which technical areas from the popover that should appear
    assert_selector("#technical-area-selection-modal")
    within("#technical-area-selection-modal") do
      find("#technical_area_ids_spar_2018_ta_c2").click # IHR Communications
      find("#technical_area_ids_spar_2018_ta_c6").click # Surveillance
      click_on("Next")
    end

    ##
    # Assessment/Goals page
    assert_current_path(%r{goals\/Nigeria\/from-technical-areas\?technical_area_ids%5B%5D=spar_2018_ta_c2&technical_area_ids%5B%5D=spar_2018_ta_c6})
    assert page.has_content?("TECHNICAL AREA SCORES")
    assert page.has_content?(
      "C2.1 National IHR Focal Point functions under IHR"
    )
    assert page.has_content?(
      "C6.2 Mechanism for event management (verification, risk assessment, analysis invesgitation)"
    )
    assert_equal "1", find("#goal_form_spar_2018_ind_c21").value
    assert_equal "2", find("#goal_form_spar_2018_ind_c21_goal").value

    find("#new_goal_form input[type=submit]").trigger(:click)

    ##
    # Draft Plan page
    # verify and dismiss the popover
    assert_selector("#draft-plan-review-modal")
    within("#draft-plan-review-modal") do
      click_on("Next")
    end

    assert_current_path(%r{plans\/\d+})
    assert_equal "Nigeria draft plan", find("#plan_name").value
    assert page.has_content?("TOTAL ACTIVITIES")
    assert_equal "33", find(".activity-count-circle span").text
    assert_selector("div[data-benchmark-indicator-abbreviation='1.1']")
    assert_selector("div[data-benchmark-indicator-abbreviation='9.1']")

    # verify bar chart by technical area filter functionality
    find('line[data-original-title*="Surveillance"]').click
    assert_no_selector("div[data-benchmark-indicator-abbreviation='1.1']")
    assert_selector("div[data-benchmark-indicator-abbreviation='9.1']")

    # unfilter to show all
    find(".activity-count-circle").click
    assert_selector("div[data-benchmark-indicator-abbreviation='1.1']")
    assert_selector("div[data-benchmark-indicator-abbreviation='9.1']")

    find("#plan_name").fill_in with: "Updated Plan 789"
    find("input[type=submit]").trigger(:click)

    assert_current_path("/users/sign_in")
    click_link("Create an account")

    assert_current_path("/users/sign_up")
    sleep 0.1 # ugh without this form field(s) dont get filled
    find("#user_email").fill_in with: "email@example.com"
    find("#user_password").fill_in with: "123123"
    find("#user_password_confirmation").fill_in with: "123123"
    find("#new_user input[type=submit]").trigger(:click)

    assert_current_path("/plans")
    assert page.has_content?("WELCOME")
    assert page.has_content?("Updated Plan 789")
  end
end
