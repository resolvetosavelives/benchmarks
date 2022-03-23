output "acr_service_endpoint_name" {
  description = "Azure DevOps Container Registry service connection name"
  value       = azuredevops_serviceendpoint_dockerregistry.acr.service_endpoint_name
}
