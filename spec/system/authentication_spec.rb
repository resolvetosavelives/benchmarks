require "system_helper"

RSpec.describe "Authentication", type: :system, js: true do
  context "devise database" do
    scenario "devise database sign up" do
      retry_on_pending_connection { visit(root_path) }

      click_on "LOG IN"
      expect(page).to have_current_path("/users/sign_in")
      expect(page).to have_content("LOG IN")

      click_link "Create an account"
      expect(page).to have_current_path("/users/sign_up")
      sleep 0.1
      find("#user_email").fill_in(with: "email@example.com")
      find("#user_password").fill_in(with: "123123")
      find("#user_password_confirmation").fill_in(with: "123123")
      find("#new_user input[type=submit]").trigger(:click)

      expect(page).to have_current_path("/plans")
      expect(page).to have_content("Welcome! You have signed up successfully.")
    end
  end

  context "azure auth" do
    before do
      Rails.application.config.azure_auth_enabled = true
      Rails.application.config.azure_auth_mocked = true
    end

    after do
      Rails.application.config.azure_auth_enabled = false
      Rails.application.config.azure_auth_mocked = false
    end

    let(:email) { "email@example.com" }

    scenario "signup during plan creation" do
      retry_on_pending_connection { visit(root_path) }

      until current_path == "/get-started"
        click_on("Get Started", match: :first)
      end
      expect(page).to have_content("LET'S GET STARTED")
      select_from_chosen "Nigeria", from: "get_started_form_country_id"
      click_on "Next"

      choose "Joint External Evaluation (JEE)"
      choose "1-year plan"
      click_on "Next"

      ##
      # Move through this without verifying much because apps_spec takes care of content
      expect(page).to have_current_path("/plan/goals/Nigeria/jee1/1-year")
      find("#new_plan input[type=submit]").trigger(:click)

      expect(page).to have_current_path(%r{^\/plans\/\d+$})

      # edit the plan name and hit save button
      find("#plan_name").fill_in(with: "Saved Nigeria Plan 789")
      find("input[type=submit]").trigger(:click)

      ##
      # On sign in page we will only have the option to log in with WHO account
      expect(page).to have_current_path("/users/sign_in")
      find("#sign-in-with-microsoft").click

      ##
      # takes us to the azure auth page (which is mocked locally)
      expect(page).to have_current_path(
        "/.auth/login/aad?post_login_redirect_uri=%2Fplans"
      )
      find("#email").fill_in(with: "email@example.com")
      find("form input[type=submit]").trigger(:click)

      ##
      # arrive at plans page and see the plan we just created
      expect(page).to have_current_path("/plans")
      expect(page).to have_content("Saved Nigeria Plan 789")
    end

    scenario "sign in & sign out" do
      retry_on_pending_connection { visit(root_path) }

      click_on "LOG IN"
      expect(page).to have_current_path("/users/sign_in")
      find("#sign-in-with-microsoft").click

      ##
      # takes us to the azure auth page (which is mocked locally)
      expect(page).to have_current_path(
        "/.auth/login/aad?post_login_redirect_uri=%2Fplans"
      )
      find("#email").fill_in(with: email)
      find("form input[type=submit]").trigger(:click)

      # arrive at plans page
      expect(page).to have_current_path("/plans")

      # logout
      click_on email
      click_on "Log Out"
      expect(page).to have_current_path("/")
      expect(page).to have_content("LOG IN")

      # Try to visit an authenticated page and see that we are still logged out
      visit(plans_path)
      expect(page).to have_current_path("/users/sign_in")
    end

    scenario "external logout from outside of the app" do
      # Verify that we aren't holding on to login information in session
      # so as not to perpetuate a session once azure has logged a user out.
      retry_on_pending_connection { visit(root_path) }

      click_on "LOG IN"
      expect(page).to have_current_path("/users/sign_in")
      find("#sign-in-with-microsoft").click

      ##
      # takes us to the azure auth page (which is mocked locally)
      expect(page).to have_current_path(
        "/.auth/login/aad?post_login_redirect_uri=%2Fplans"
      )
      find("#email").fill_in(with: email)
      find("form input[type=submit]").trigger(:click)

      # arrive at plans page
      expect(page).to have_current_path("/plans")

      # Explicitly remove the cookie to immitate azure logging the user out
      # without an explicit visit to the app's logout page.
      # This manipulates our mocked azure middleware to behave like real Azure
      # which stops sending the header when the cookie is no longer present.
      page.driver.remove_cookie(Azure::MockSessionsController::COOKIE)

      # Now that the cookie is not being sent, we should be logged out.
      visit(plans_path)
      expect(page).to have_current_path("/users/sign_in")
    end

    scenario "devise database (email & password) sign up while Azure enabled" do
      retry_on_pending_connection { visit(root_path) }

      click_on "LOG IN"
      expect(page).to have_current_path("/users/sign_in")
      expect(page).to have_content("LOG IN")

      click_link "Create an account"
      expect(page).to have_current_path("/users/sign_up")
      sleep 0.1
      find("#user_email").fill_in(with: "email@example.com")
      find("#user_password").fill_in(with: "123123")
      find("#user_password_confirmation").fill_in(with: "123123")
      find("#new_user input[type=submit]").trigger(:click)

      expect(page).to have_current_path("/plans")
      expect(page).to have_content("Welcome! You have signed up successfully.")

      click_on email
      click_on "Log Out"
      expect(page).to have_current_path("/")
      expect(page).to have_content("LOG IN")

      # Try to visit an authenticated page and see that we are still logged out
      visit(plans_path)
      expect(page).to have_current_path("/users/sign_in")
    end
  end
end
