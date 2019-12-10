require File.expand_path('./test/test_helper')
require 'capybara/cuprite'
require 'capybara/rails'
require 'capybara/minitest'

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :chrome, screen_size: [1400, 1400]
end
