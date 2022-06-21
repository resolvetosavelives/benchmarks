output "application_id" {
  description = "Application ID, used to configure authentication"
  value       = azuread_application.app.application_id
}
output "client_secret" {
  description = "Application client secret, used to configure authentication"
  value       = azuread_application_password.client_secret.value
}

