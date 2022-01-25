Sentry.init do |config|
  config.enabled_environments = %w[staging production]
  if Rails.env.production? && !Rails.application.config.asset_compilation
    config.dsn = Rails.application.credentials.sentry_dsn!
    config.environment = Rails.application.credentials.sentry_current_env!
  else
    config.dsn = Rails.application.credentials.sentry_dsn
    config.environment = Rails.application.credentials.sentry_current_env
  end
end
