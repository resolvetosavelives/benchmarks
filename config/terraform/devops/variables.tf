variable "resource_group_name" {
  type = string
}
variable "app_service_name" {
  type = string
}
variable "azure_subscription_service_connection" {
  type = string
}
variable "container_registry_domain" {
  type = string
}
variable "container_repository" {
  type = string
}
variable "RAILS_MASTER_KEY" {
  type      = string
  sensitive = true
}
