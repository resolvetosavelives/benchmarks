ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require "minitest/spec"
require "minitest/reporters"
Minitest::Reporters.use! [
  Minitest::Reporters::SpecReporter.new,
  #Minitest::Reporters::MeanTimeReporter.new
]


#class ActiveSupport::TestCase
#  # any configs or customizations can go here
#end

##
# for FactoryBot support
class Minitest::Spec
  include FactoryBot::Syntax::Methods
end
class Minitest::Unit::TestCase
  include FactoryBot::Syntax::Methods
end
class ActionDispatch::IntegrationTest
  include FactoryBot::Syntax::Methods
end
