Sentry.init do |config|
  config.enabled_environments = %w[staging production]
  config.dsn =
    Rails.application.credentials.send(
      Rails.env.production? ? :sentry_dsn! : :sentry_dsn
    )
  config.environment =
    Rails.application.credentials.send(
      Rails.env.production? ? :sentry_current_env! : :sentry_current_env
    )
end
