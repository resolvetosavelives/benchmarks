variable "resource_group_name" {
  description = "Resource group name containing all resources"
  type        = string
}
variable "app_service_name" {
  description = "App Service Name, also used for ACR name by converting to lowercase and replacing special characters"
  type        = string
}
variable "container_repository" {
  description = "Docker image name, also appended with _builder for the builder image."
  type        = string
}
variable "production_database_url" {
  description = "DATABASE_URL for production app"
  type        = string
  sensitive   = true
}
variable "staging_database_url" {
  description = "DATABASE_URL for staging app"
  type        = string
  sensitive   = true
}
variable "RAILS_MASTER_KEY" {
  description = "RAILS_MASTER_KEY from config/master.key"
  type        = string
  sensitive   = true
}
variable "azure_auth_application_id_staging" {
  description = "Azure Auth Application ID (staging)"
  type        = string
}
variable "azure_auth_application_id_preview" {
  description = "Azure Auth Application ID (preview)"
  type        = string
}
variable "azure_auth_application_id_production" {
  description = "Azure Auth Application ID (production)"
  type        = string
}
variable "azure_auth_client_secret_staging" {
  description = "Azure Auth Client Secret (staging)"
  type        = string
  sensitive   = true
}
variable "azure_auth_client_secret_preview" {
  description = "Azure Auth Client Secret (preview)"
  type        = string
  sensitive   = true
}
variable "azure_auth_client_secret_production" {
  description = "Azure Auth Client Secret (production)"
  type        = string
  sensitive   = true
}
