ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  ##
  # for FactoryBot support
  class Minitest::Unit::TestCase
    include FactoryBot::Syntax::Methods
  end
  class ActionDispatch::IntegrationTest
    include FactoryBot::Syntax::Methods
  end
end
