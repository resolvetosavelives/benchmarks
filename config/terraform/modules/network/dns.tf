# The private DNS zone is used to allow the application gateway to find the app's private endpoint
resource "azurerm_private_dns_zone" "zone" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = var.resource_group_name
  tags = {
    "ROLE"        = "IHR benchmark applications"
    "SERVICETYPE" = "APPLICATION"
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnet-dns-link" {
  name                  = "privatelink.azurewebsites.net"
  private_dns_zone_name = azurerm_private_dns_zone.zone.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  resource_group_name   = var.resource_group_name
}

# The private DNS zone is used to allow the application gateway to find the app's private endpoint
resource "azurerm_private_dns_zone" "db-zone" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = var.resource_group_name
  tags = {
    "ROLE"        = "IHR benchmark applications"
    "SERVICETYPE" = "APPLICATION"
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnet-db-dns-link" {
  name                  = "db-zone"
  private_dns_zone_name = azurerm_private_dns_zone.db-zone.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  resource_group_name   = var.resource_group_name
}