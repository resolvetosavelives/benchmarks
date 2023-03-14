Rails.application.config.email_from =
  ENV.fetch("EMAIL_FROM", "no-reply@resolvetosavelives.org")
