require_relative "boot"

require "rails"

%w[
  active_record/railtie
  active_storage/engine
  action_controller/railtie
  action_view/railtie
  action_mailer/railtie
  active_job/railtie
  sprockets/railtie
].each do |railtie|
  begin
    require railtie
  rescue LoadError
  end
end

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# RTSL is an abbreviation for Resolve To Save Lives, which is the org.
module RtslBenchmarks
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1
    config.assets.enabled = false
    config.add_autoload_paths_to_load_path = false
    config.middleware.use Rack::Attack

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # This setting is true during asset compilation to avoid forcing secrets to be loaded
    config.asset_compilation = ENV["ASSET_COMPILATION"]

    # Set by Azure when deployed to app-service.
    config.website_hostname = ENV["WEBSITE_HOSTNAME"]
  end
end
