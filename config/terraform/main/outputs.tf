output "resource_group_name" {
  description = "Resource group name for current workspace"
  value       = local.resource_group_name
}
output "app_service_name" {
  description = "App service name used for running app service pipeline tasks"
  value       = module.application.app_service_name
}
output "container_registry_domain" {
  description = "Container registry domain"
  value       = module.application.acr_login_server
}
output "container_repository" {
  description = "Container registry repository name"
  value       = local.container_repository
}
# output "acr_service_endpoint_name" {
#   description = "Azure DevOps Container Registry service connection name"
#   value       = module.devops.acr_service_endpoint_name
# }
