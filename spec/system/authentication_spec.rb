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
end
