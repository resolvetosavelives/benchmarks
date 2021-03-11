require 'test_helper'

require 'capybara/cuprite'
require 'capybara_helper'
require 'minitest/rails/capybara'

Capybara.default_max_wait_time = 2
Capybara.default_normalize_ws = true
Capybara.default_driver = Capybara.javascript_driver = :cuprite

Capybara.register_driver(:cuprite) do |app|
  Capybara::Cuprite::Driver.new(
    app,
    window_size: [1200, 800],
    # See additional options for Dockerized environment in the respective section of this article
    browser_options: {},
    # Increase Chrome startup wait time (required for stable CI builds)
    process_timeout: 30,
    # Enable debugging capabilities
    inspector: true,
    # Allow running Chrome in a headful mode by setting HEADLESS env
    # var to a falsey value
    headless: !ENV['HEADLESS'].in?(%w[n 0 no false])
  )
end

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :cuprite, using: :chrome, screen_size: [1400, 1400]

  register_spec_type(self) { |desc, *addl| addl.include? :system }

  include CapybaraHelper

  def save_state_from_server(page)
    state_from_server = extract_state_from_server(page)
    write_state_to_file('state_from_server', state_from_server)
  end

  def save_state_influenza(page)
    state_from_server = extract_state_from_server(page)
    write_state_to_file('state_from_server_with_influenza', state_from_server)
  end

  def save_state_influenza_and_cholera(page)
    state_from_server = extract_state_from_server(page)
    write_state_to_file(
      'state_from_server_with_influenza_and_cholera',
      state_from_server
    )
  end

  def extract_state_from_server(page)
    script_element = page.find('#state_from_server', visible: false)
    state_from_server_js_content = script_element.native.all_text
    first_bracket_position = state_from_server_js_content.index('{')
    last_bracket_position_reversed =
      state_from_server_js_content.reverse.index('}')
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
      Rails.root.join('test', 'fixtures', 'files', "#{file_name}.json")
    File.open(state_from_server_json_file, 'w') do |f|
      f.write(JSON.pretty_generate(file_data))
    end
  end
end
