variable "resource_group_name" {
  type = string
}
variable "app_service_name" {
  type = string
}
variable "acr_service_endpoint_name" {
  type = string
}
variable "container_registry_domain" {
  type = string
}
variable "container_registry_username" {
  type = string
}
variable "container_registry_password" {
  type      = string
  sensitive = true
}
variable "container_repository" {
  type = string
}
variable "RAILS_MASTER_KEY" {
  type      = string
  sensitive = true
}
