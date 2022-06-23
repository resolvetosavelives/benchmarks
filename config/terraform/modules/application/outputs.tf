output "app_service_name" {
  description = "Azure Web Application Service name"
  value       = azurerm_app_service.app_service.name
}
