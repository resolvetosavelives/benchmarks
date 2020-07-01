require File.expand_path("./test/test_helper")
require "capybara/cuprite"
require "minitest/rails/capybara"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :chrome, screen_size: [1400, 1400]

  register_spec_type(self) { |desc, *addl| addl.include? :system }

  def save_state_from_server(page)
    state_from_server_script_element = page.find("#state_from_server", visible: false)
    state_from_server_js_content = state_from_server_script_element.native.all_text
    first_bracket_position = state_from_server_js_content.index('{')
    last_bracket_position_reversed = state_from_server_js_content.reverse.index('}')
    last_bracket_position = state_from_server_js_content.size - last_bracket_position_reversed
    last_bracket_position -= 1 # to chop off the semicolon
    state_from_server_json = state_from_server_js_content[first_bracket_position..last_bracket_position]
    state_from_server = JSON.parse(state_from_server_json)
    state_from_server_json_file = Rails.root.join("test", "fixtures", "files", "state_from_server.json")
    File.open(state_from_server_json_file, "w") do |f|
      f.write(JSON.pretty_generate(state_from_server))
    end
  end
end
