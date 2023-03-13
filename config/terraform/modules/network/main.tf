locals {
  zones = ["1", "2", "3"] #Availability zones to spread the Application Gateway over. They are also only supported for v2 SKUs.

}
# Originally from tutorial: https://faun.pub/build-an-azure-application-gateway-with-terraform-8264fbd5fa42

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.namespace}-vnet"
  address_space       = ["10.15.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
}

# Public IP
resource "azurerm_public_ip" "agw" {
  name                = "${upper(var.namespace)}-AGW-IP"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = local.zones
  domain_name_label   = var.namespace
}
