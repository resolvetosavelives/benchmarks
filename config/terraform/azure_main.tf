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

resource "azurerm_resource_group" "who_ihr_benchmarks_terraform" {
  name     = "${local.app_name}-terraform"
  location = local.azure_location
}
resource "azurerm_resource_group" "who_ihr_benchmarks_sandbox" {
  name     = "${local.app_name}-sandbox"
  location = local.azure_location
}
resource "azurerm_resource_group" "who_ihr_benchmarks_production" {
  name     = "${local.app_name}-production"
  location = local.azure_location
}
