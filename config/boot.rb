ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.
begin
  require "bootsnap/setup" # Speed up boot time by caching expensive operations.
rescue LoadError
  # bootsnap is an optional dependency, so if we don't have it it's fine
  # Do not load in production
  nil
end
