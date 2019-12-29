ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/spec"
require "minitest/mock"
require "minitest/reporters"
Minitest::Reporters.use! [
  Minitest::Reporters::SpecReporter.new,
  # Minitest::Reporters::MeanTimeReporter.new
]

##
# for FactoryBot support
class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods
end
class Minitest::Spec
  include FactoryBot::Syntax::Methods
end
class Minitest::Unit::TestCase
  include FactoryBot::Syntax::Methods
end
class ActionDispatch::IntegrationTest
  include FactoryBot::Syntax::Methods
end
