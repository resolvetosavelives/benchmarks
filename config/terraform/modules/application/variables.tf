variable "resource_group_name" {
  description = "Resource group name containing all resources"
  type        = string
}
variable "app_service_name" {
  description = "App Service Name, also used for ACR name by converting to lowercase and replacing special characters"
  type        = string
}
variable "container_registry_domain" {
  description = "Azure Container Registry login_server"
  type        = string
}
variable "container_registry_username" {
  description = "Azure Container Registry admin username"
  type        = string
}
variable "container_registry_password" {
  description = "Azure Container Registry admin password"
  type        = string
  sensitive   = true
}
variable "container_repository" {
  description = "Docker image name, also appended with _builder for the builder image."
  type        = string
}
variable "database_url" {
  description = "DATABASE_URL for production app"
  type        = string
  sensitive   = true
}
variable "preview_database_url" {
  description = "DATABASE_URL for preview slot app"
  type        = string
  sensitive   = true
}
variable "RAILS_MASTER_KEY" {
  description = "RAILS_MASTER_KEY from config/master.key"
  type        = string
  sensitive   = true
}
variable "azure_auth_application_id_preview" {
  description = "Azure Auth Application ID (preview)"
  type        = string
}
variable "azure_auth_application_id" {
  description = "Azure Auth Application ID (production)"
  type        = string
}
variable "azure_auth_client_secret_preview" {
  description = "Azure Auth Client Secret (preview)"
  type        = string
  sensitive   = true
}
variable "azure_auth_client_secret" {
  description = "Azure Auth Client Secret (production)"
  type        = string
  sensitive   = true
}
