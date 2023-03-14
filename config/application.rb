require_relative "boot"

require "rails"

# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# RTSL is an abbreviation for Resolve To Save Lives, which is the org.
module RtslBenchmarks
  class Application < Rails::Application
    # used where we display the app name, such as the admin panel pages
    config.app_name = "IHR Benchmarks"
    config.site_title = "IHR Benchmark"
    config.logo = { src: "who-logo.svg", alt: "WHO Logo" }
    config.copyright = -> do
      "© #{Date.today.year} World Health Organization. All rights reserved."
    end
    config.contact_email =
      ENV.fetch("CONTACT_EMAIL", "asantos@resolvetosavelives.org")

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0
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

    config.application_host = ENV["APPLICATION_HOST"]

    # Set by Azure when integrated auth is enabled.
    # https://docs.microsoft.com/en-us/azure/app-service/overview-authentication-authorization
    config.azure_auth_enabled = ENV["WEBSITE_AUTH_ENABLED"].present?

    config.commit_sha = ENV["COMMIT_SHA"]
    config.docker_image_tag = ENV["DOCKER_IMAGE_TAG"]
  end
end
