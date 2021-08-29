//
// Azure Virtual Network concepts and best practices:
//   https://docs.microsoft.com/en-us/azure/virtual-network/concepts-and-best-practices
//   - Ensure non-overlapping address spaces.
//   - Your subnets should not cover the entire address space of the VNet.
//   - It is recommended you have fewer large VNets rather than multiple small VNets.
//   - TODO: Secure your VNets by assigning Network Security Groups (NSGs) to the subnets beneath them.
//
resource "azurerm_virtual_network" "primary" { // the primary back-of-house vnet
  name                = "vnet-primary"
  location            = azurerm_resource_group.who_ihr_benchmarks.location
  resource_group_name = azurerm_resource_group.who_ihr_benchmarks.name
  address_space       = ["10.1.0.0/16"]
//  dns_servers         = ["10.0.0.4", "10.0.0.5"]
}
resource "azurerm_private_dns_zone" "pdns_acr01" {
  name                = "privatelink.azurecr.io"
  resource_group_name = azurerm_resource_group.who_ihr_benchmarks.name
}
resource "azurerm_private_dns_zone" "pdns_db01" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.who_ihr_benchmarks.name
}
resource "azurerm_private_dns_zone_virtual_network_link" "pdnslink_primary" {
  name                  = "test"
  resource_group_name   = azurerm_resource_group.who_ihr_benchmarks.name
  private_dns_zone_name = azurerm_private_dns_zone.pdns_acr01.name
  virtual_network_id    = azurerm_virtual_network.primary.id
}
resource "azurerm_subnet" "build_support_services" {
  name = "subnet-build-support-services"
  resource_group_name  = azurerm_resource_group.who_ihr_benchmarks.name
  virtual_network_name = azurerm_virtual_network.primary.name
  address_prefixes     = ["10.1.2.0/24"]
  enforce_private_link_endpoint_network_policies = true
}




//resource "azurerm_subnet" "app_service_integration" {
//  name = "subnet-app-service-integration"
//  resource_group_name  = azurerm_resource_group.who_ihr_benchmarks.name
//  virtual_network_name = azurerm_virtual_network.primary.name
//  address_prefixes     = ["10.1.1.0/24"]
//  enforce_private_link_endpoint_network_policies = true
//  delegation {
//    name = "example-delegation"
//
//    service_delegation {
//      name    = "Microsoft.Web/serverFarms"
//      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
//    }
//  }
//}


resource "azurerm_subnet" "app_critical_services" {
  name = "subnet-app-critical-services"
  resource_group_name  = azurerm_resource_group.who_ihr_benchmarks.name
  virtual_network_name = azurerm_virtual_network.primary.name
  address_prefixes     = ["10.1.3.0/24"]
  enforce_private_link_endpoint_network_policies = true
}


//resource "azurerm_subnet" "subnet_for_management" {
//  name = "subnet-management"
//  resource_group_name  = azurerm_resource_group.who_ihr_benchmarks.name
//  virtual_network_name = azurerm_virtual_network.vnet_primary.name
//  address_prefixes     = ["10.1.4.0/24"]
//  enforce_private_link_endpoint_network_policies = true
//}
