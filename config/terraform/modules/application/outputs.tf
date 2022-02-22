output "acr_login_server" {
  description = "Azure Container Registry login server"
  value       = azurerm_container_registry.acr.login_server
}
output "acr_admin_username" {
  description = "Azure Container Registry admin username"
  value       = azurerm_container_registry.acr.admin_username
}
output "acr_admin_password" {
  description = "Azure Container Registry admin password"
  value       = azurerm_container_registry.acr.admin_password
  sensitive   = true
}
output "app_service_name" {
  description = "Azure Web Application Service name"
  value       = azurerm_app_service.app_service.name
}
