require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# RTSL is an abbreviation for Resolve To Save Lives, which is the org.
module RtslBenchmarks
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0
    config.assets.enabled = false
    config.add_autoload_paths_to_load_path = false
    config.middleware.use Rack::Attack

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
