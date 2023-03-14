Sentry.init do |config|
  config.enabled_environments = %w[staging production]
  if Rails.env.production? && !Rails.application.config.asset_compilation
    config.dsn =
      ENV.fetch("SENTRY_DSN") { Rails.application.credentials.sentry_dsn! }
    config.environment =
      ENV.fetch("SENTRY_CURRENT_ENV") do
        Rails.application.credentials.sentry_current_env!
      end
  else
    config.dsn =
      ENV.fetch("SENTRY_DSN") { Rails.application.credentials.sentry_dsn }
    config.environment =
      ENV.fetch("SENTRY_CURRENT_ENV") do
        Rails.application.credentials.sentry_current_env
      end
  end
end
