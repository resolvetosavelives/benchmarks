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
variable "staging_aad_application_id" {
  description = "The Azure AD Application ID for the staging app"
  type        = string
}
variable "preview_aad_application_id" {
  description = "The Azure AD Application ID for the preview app"
  type        = string
}
variable "production_aad_application_id" {
  description = "The Azure AD Application ID for the production app"
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
