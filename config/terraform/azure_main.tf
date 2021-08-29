#
# SECTION: Variables used
#
//variable "DATABASE_URL" {
//  type = string
//  sensitive = true
//}
//variable "DOCKER_REGISTRY_SERVER_URL" {
//  type = string
//}
//variable "DOCKER_REGISTRY_SERVER_USERNAME" {
//  type = string
//  sensitive = true
//}
//variable "DOCKER_REGISTRY_SERVER_PASSWORD" {
//  type = string
//  sensitive = true
//}
//variable "RAILS_MASTER_KEY" {
//  type = string
//  sensitive = true
//}

resource "azurerm_resource_group" "who_ihr_benchmarks" {
  name     = local.resource_group_name
  location = "eastus2"
}

//resource "azurerm_network_watcher" "network_watcher" {
//  name                = "network-watcher"
//  location            = azurerm_resource_group.who_ihr_benchmarks.location
//  resource_group_name = azurerm_resource_group.who_ihr_benchmarks.name
//}
