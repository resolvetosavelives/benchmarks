require File.expand_path("./test/test_helper")
require "capybara/cuprite"
require "minitest/rails/capybara"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :chrome, screen_size: [1400, 1400]

  register_spec_type(self) do |desc, *addl|
    addl.include? :system
  end
end
