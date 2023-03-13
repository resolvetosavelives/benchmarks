variable "resource_group_name" {
  description = "Resource group name containing all resources"
  type        = string
}
variable "location" {
  description = "The location of the resource group"
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
variable "container_repository" {
  description = "Docker image name, also appended with _builder for the builder image."
  type        = string
}
variable "azure_auth_application_id" {
  description = "Azure Auth Application ID"
  type        = string
}
variable "azure_auth_client_secret" {
  description = "Azure Auth Client Secret"
  type        = string
  sensitive   = true
}
variable "app_settings" {
  description = "A map of all the app settings env vars which need to be passed in (and can't be derived from this module)"
  type        = map(any)
  sensitive   = true
}
variable "tenant_id" {
  description = "The Azure Active Directory tenant ID that should be used for authenticating requests to the key vault. Changing this forces a new resource to be created.y"
  type        = string
}
variable "domain_name" {
  description = "The domain name for the application gateway. The app service uses this to set the url for internal links and for sendgrid HELO checking"
  type        = string
}
variable "sendgrid_api_key" {
  description = "The API key to use to connect to the sendgrid api"
  type        = string
  sensitive   = true
}
variable "app_outbound_subnet_id" {
  description = "The subnet to do the app service vnet integration for outbound traffic from the app"
  type        = string
}