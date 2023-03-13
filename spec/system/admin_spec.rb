require "system_helper"

RSpec.describe "Managing", type: :system, js: true do
  describe "User Resources" do
    let(:email) { "test@example.com" }

    context "as Admin" do
      scenario "can view a list of users" do
        retry_on_pending_connection { visit(root_path) }

        login_as(email, role: "admin")

        ##
        # navigate to the users listing page
        visit_manage_users
        expect(page).to have_content("User accounts of IHR Benchmarks")
        expect(page).to have_content(email)
      end

      scenario "can make users admin" do
        retry_on_pending_connection { visit(root_path) }

        login_as(email, role: "admin")

        users = create_list(:user, 3)

        visit_manage_users

        within "tr[data-resource-id=\"#{users.first.id}\"]" do
          check("Select item")
        end
        within "tr[data-resource-id=\"#{users.second.id}\"]" do
          check("Select item")
        end

        click_on "Actions"
        click_link "Make Admin"

        expect(page).to have_content("Are you sure?")
        click_button "Make Admin"

        sleep 0.4

        user1_is_admin = find_is_admin_cell(users.first.id)
        expect(user1_is_admin).to have_css(is_admin_css)

        user2_is_admin = find_is_admin_cell(users.second.id)
        expect(user2_is_admin).to have_css(is_admin_css)
      end

      scenario "can remove users from being admins" do
        retry_on_pending_connection { visit(root_path) }

        login_as(email, role: "admin")

        admins = create_list(:user, 2, role: "admin")

        visit_manage_users

        within "tr[data-resource-id=\"#{admins.first.id}\"]" do
          check("Select item")
        end
        within "tr[data-resource-id=\"#{admins.second.id}\"]" do
          check("Select item")
        end

        click_on "Actions"
        click_link "Remove Admin"

        expect(page).to have_content("Are you sure?")
        click_button "Remove Admin"

        sleep 0.4

        user1_is_admin = find_is_admin_cell(admins.first.id)
        expect(user1_is_admin).to have_css(is_not_admin_css)

        user2_is_admin = find_is_admin_cell(admins.second.id)
        expect(user2_is_admin).to have_css(is_not_admin_css)
      end

      scenario "cannot remove own admin privileges" do
        retry_on_pending_connection { visit(root_path) }

        login_as(email, role: "admin")
        user = User.last
        admins = create_list(:user, 2, role: "admin")

        visit_manage_users

        within "tr[data-resource-id=\"#{user.id}\"]" do
          check("Select item")
        end
        within "tr[data-resource-id=\"#{admins.first.id}\"]" do
          check("Select item")
        end

        click_on "Actions"
        click_link "Remove Admin"

        expect(page).to have_content("Are you sure?")
        click_button "Remove Admin"

        sleep 0.4

        expect(page).to have_content(
          "You cannot remove your own admin privileges. No users have been changed."
        )

        user1_is_admin = find_is_admin_cell(user.id)
        expect(user1_is_admin).to have_css(is_admin_css)

        user2_is_admin = find_is_admin_cell(admins.first.id)
        expect(user2_is_admin).to have_css(is_admin_css)
      end

      scenario "can edit user affiliation" do
        retry_on_pending_connection { visit(root_path) }

        login_as(email)

        User.last.update!(role: "admin")

        users = create_list(:user, 2)

        ##
        # navigate to the users listing page
        visit("/manage/resources/users")

        editing_user_id = users.first.id

        # Click on edit link
        find(
          "a[data-resource-id=\"#{editing_user_id}\"][data-control=\"edit\"]"
        ).click
        expect(page).to have_current_path(
          "/manage/resources/users/#{editing_user_id}/edit?via_view=index"
        )

        # Edit affiliation and save
        select "Academia", from: "user_affiliation"
        click_button "Save"
        expect(page).to have_current_path("/manage/resources/users")
        expect(page).to have_content("User was successfully updated.")

        # Check if affiliation was updated
        affiliation_cell =
          find("tr[data-resource-id=\"#{editing_user_id}\"]").find(
            "td[data-field-id=\"affiliation\"]"
          )
        expect(affiliation_cell).to have_content("Academia")
      end
    end

    context "as a regular User" do
      scenario "cannot view list of users and is instead redirected /plans with a flash message" do
        retry_on_pending_connection { visit(root_path) }

        login_as(email)

        ##
        # navigate to the users listing page
        visit("/manage/resources/users")
        expect(page).to have_current_path("/plans")
        expect(page).to have_content("You are not authorized to do that")
        expect(page).to have_content("WELCOME")
        expect(page).to have_content("You haven't started any plans yet")
      end
    end

    context "as an unauthenticated User" do
      scenario "cannot view list of users and is instead redirected sign_in with a flash message" do
        retry_on_pending_connection { visit(root_path) }

        ##
        # navigate to the users listing page
        visit("/manage/resources/users")
        expect(page).to have_current_path("/users/sign_in")
        expect(page).to have_content(
          "You need to sign in or sign up before continuing"
        )
        expect(page).to have_content("LOG IN")
        expect(page).to have_content("Don't have an account?")
      end
    end
  end
end
