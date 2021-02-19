Sentry.init do |config|
  # TODO: use sentry advanced data scrubbing instead:
  # https://docs.sentry.io/product/data-management-settings/advanced-datascrubbing/
  # config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
  config.enabled_environments = %w[staging production]
end
