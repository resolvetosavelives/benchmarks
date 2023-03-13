output "app_service_name" {
  description = "Azure Web Application Service name"
  value       = azurerm_linux_web_app.app_service.name
}
output "app_id" {
  description = "The id of the Azurerm Linux Web App, used for later routing"
  value       = azurerm_linux_web_app.app_service.id
}