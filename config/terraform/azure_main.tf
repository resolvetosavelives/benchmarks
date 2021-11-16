#
# SECTION: Variables used
#
variable "DATABASE_URL_FOR_PIPELINE" {
  type      = string
  sensitive = true
}
variable "DATABASE_URL_FOR_STAGING" {
  type      = string
  sensitive = true
}
variable "DOCKER_REGISTRY_SERVER_URL" {
  type = string
}
variable "DOCKER_REGISTRY_SERVER_USERNAME" {
  type      = string
  sensitive = true
}
variable "DOCKER_REGISTRY_SERVER_PASSWORD" {
  type      = string
  sensitive = true
}
variable "RAILS_MASTER_KEY" {
  type      = string
  sensitive = true
}

resource "azurerm_resource_group" "who_ihr_benchmarks" {
  name     = local.resource_group_name
  # FIXME: WHO requires use of North or West Europe Azure regions
  location = "eastus2"
}
