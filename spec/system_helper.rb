require "rails_helper"
require "capybara/rails"
require "capybara/rspec"
require "capybara/cuprite"

# Load configuration files and helpers
Dir[File.join(__dir__, "system/support/*.rb")].each { |file| require file }

RSpec.configure { |config| config.include CapybaraHelpers, type: :system }
