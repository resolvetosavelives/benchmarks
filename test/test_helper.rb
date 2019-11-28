ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require "minitest/spec"

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
