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

# per WHO Azure project policy, ResourceGroup names are UPPERCASE-WITH-HYPHENS
resource "azurerm_resource_group" "who_ihr_benchmarks_terraform" {
  name     = upper("${local.app_name}-terraform-EUW-RG01")
  location = local.azure_location
}
resource "azurerm_resource_group" "who_ihr_benchmarks_sandbox" {
  name     = upper("${local.app_name}-sandbox-EUW-RG01")
  location = local.azure_location
}
resource "azurerm_resource_group" "who_ihr_benchmarks_production" {
  name     = upper("${local.app_name}-production-EUW-RG01")
  location = local.azure_location
}
