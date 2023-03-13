require "ferrum"

module CapybaraHelpers
  def login_as(email, role: "user")
    click_link "LOG IN" unless current_path == "/users/sign_in"
    expect(page).to have_current_path("/users/sign_in")

    user =
      User.find_by(email: email) ||
        User.create!(email: email, password: "abc123")
    user.update!(role: role)

    find("#email").fill_in(with: email)
    find("#password").fill_in(with: "abc123")
    find("form input[type=submit]").trigger(:click)
    expect(page).to have_current_path("/plans")

    # Refresh page after changing role
    visit current_path
  end

  ##
  # usage: select_from_chosen('Option', from: 'id_of_field')
  #   example, Get Started form: select_from_chosen('Armenia', from: 'get_started_form_country_id')
  def select_from_chosen(item_text, options)
    field = find_field(options[:from], visible: false)
    find("##{field[:id]}_chosen").click
    find("##{field[:id]}_chosen ul.chosen-results li", text: item_text).click
  end

  # Someday Ferrum will have a better way to handle that pending connection issue.
  # For now, this prevents system tests from flaking on that particular error.
  def retry_on_pending_connection
    retries = 0

    begin
      yield
    rescue Ferrum::PendingConnectionsError
      retries += 1
      unless retries > 3
        puts "Ferrum failed with PendingConnectionsError, retrying. (Retry ##{retries})"
        retry
      end
    end
  end

  def save_state_from_server(page)
    state_from_server = extract_state_from_server(page)
    write_state_to_file("state_from_server", state_from_server)
  end

  def save_state_influenza(page)
    state_from_server = extract_state_from_server(page)
    write_state_to_file("state_from_server_with_influenza", state_from_server)
  end

  def save_state_influenza_and_cholera(page)
    state_from_server = extract_state_from_server(page)
    write_state_to_file(
      "state_from_server_with_influenza_and_cholera",
      state_from_server
    )
  end

  def extract_state_from_server(page)
    script_element = page.find("#state_from_server", visible: false)
    state_from_server_js_content = script_element.native.all_text
    first_bracket_position = state_from_server_js_content.index("{")
    last_bracket_position_reversed =
      state_from_server_js_content.reverse.index("}")
    last_bracket_position =
      state_from_server_js_content.size - last_bracket_position_reversed
    last_bracket_position -= 1 # to chop off the semicolon
    state_from_server_json =
      state_from_server_js_content[
        first_bracket_position..last_bracket_position
      ]
    JSON.parse(state_from_server_json)
  end

  def write_state_to_file(file_name, file_data)
    state_from_server_json_file =
      Rails.root.join("spec", "fixtures", "files", "#{file_name}.json")
    File.open(state_from_server_json_file, "w") do |f|
      f.write(JSON.pretty_generate(file_data))
    end
  end

  def find_is_admin_cell(user_id)
    find("tr[data-resource-id=\"#{user_id}\"]").find(
      "td[data-field-id=\"is_admin\"]"
    )
  end

  # We use a css color class to tell whether row is marked as admin or not since
  # there's nothing else on the page to check against
  def is_admin_css
    ".text-green-600"
  end

  def is_not_admin_css
    ".text-red-500"
  end

  def visit_manage_users
    expect(page).to have_current_path("/plans")
    click_link "Users"
    expect(page).to have_current_path("/manage/resources/users")
  end
end
