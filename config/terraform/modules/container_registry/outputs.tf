output "acr_admin_password" {
  value       = azurerm_container_registry.acr.admin_password
  description = "the admin password from the container registry for the app image"
}
output "acr_admin_username" {
  value       = azurerm_container_registry.acr.admin_username
  description = "the admin username from the container registry for the app image"
}
output "acr_domain" {
  value       = azurerm_container_registry.acr.login_server
  description = "the login server url from the container registry for the app image"
}
output "acr_name" {
  value       = azurerm_container_registry.acr.name
  description = "the name of the container registry for the app image"
}
output "acr_id" {
  value       = azurerm_container_registry.acr.id
  description = "the id of the container registry for the app image"
}