# Outputs are added to the variables available in the azure pipeline
output "RESOURCE_GROUP_NAME" {
  description = "Resource group name for current workspace"
  value       = module.main.resource_group_name
}
output "APP_SERVICE_NAME" {
  description = "App service name for running app service pipeline tasks"
  value       = module.main.app_service_name
}
output "CONTAINER_REGISTRY_DOMAIN" {
  description = "Container registry domain"
  value       = module.main.container_registry_domain
}
output "CONTAINER_REPOSITORY" {
  description = "Container registry repository name"
  value       = module.main.container_repository
}
# output "ACR_SERVICE_ENDPOINT_NAME" {
#   description = "Azure DevOps Container Registry service connection name"
#   value       = module.main.acr_service_endpoint_name
# }
