Rails.application.config.email_from =
  ENV.fetch("EMAIL_FROM", "no-reply@resolvetosavelives.org")
Rails.application.config.contact_email =
  ENV.fetch("CONTACT_EMAIL", "asantos@resolvetosavelives.org")
