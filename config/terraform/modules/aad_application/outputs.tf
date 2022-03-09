output "application_id" {
  description = "Application ID, used to configure authentication"
  value       = azuread_application.app.application_id
}
