#
# with the Basic sku we get less bandwidth, modest performance and storage, and no privacy (could be accessed by public internet if the URL is discovered)
# more info on sku Service tier features and limits: https://docs.microsoft.com/en-us/azure/container-registry/container-registry-skus
#
resource "azurerm_container_registry" "acr" {
  // Azure rules for name: alpha numeric characters only are allowed, lower case, must be globally unique
  name                     = "acr01whoihrbenchmarks"
  resource_group_name      = azurerm_resource_group.who_ihr_benchmarks.name
  location                 = azurerm_resource_group.who_ihr_benchmarks.location
  sku                      = "Premium"
  admin_enabled            = true
  public_network_access_enabled = false
}
resource "azurerm_private_endpoint" "pend_acr" {
  name                = "pend-acr"
  location            = azurerm_resource_group.who_ihr_benchmarks.location
  resource_group_name = azurerm_resource_group.who_ihr_benchmarks.name
  subnet_id           = azurerm_subnet.build_support_services.id
  private_dns_zone_group {
    name                 = "pdnsz-acr"
    private_dns_zone_ids = [azurerm_private_dns_zone.pdns_acr01.id]
  }
  private_service_connection {
    name                           = "psc-acr"
    private_connection_resource_id = azurerm_container_registry.acr.id
    is_manual_connection           = false
    subresource_names = ["registry"]
  }
}
// As of Sunday 3:20pm ET
// REGISTRY_PRIVATE_IP: 10.1.2.5
// DATA_ENDPOINT_PRIVATE_IP: 10.1.2.4
// whoihrbenchmarks.azurecr.io :: whoihrbenchmarks.eastus2.data.azurecr.io

resource "azurerm_postgresql_server" "who_ihr_benchmarks_db_server" {
  name                = "psqldb-who-ihr-benchmarks"
  location            = azurerm_resource_group.who_ihr_benchmarks.location
  resource_group_name = azurerm_resource_group.who_ihr_benchmarks.name
  sku_name = "B_Gen5_2" // or B_Gen5_1

  storage_mb                   = 5120
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  # these wont be real credentials once this is working but for now these are good enough during development
  # TODO: remove these fake credentials and replace with using a secret store
  administrator_login          = "fyxzCNQUqNrd"
  administrator_login_password = "Lo4YdiJcggrN9TfPagCW2AsMtFbQ8R6N"
  version                      = "11"
  ssl_enforcement_enabled      = true
  ssl_minimal_tls_version_enforced = "TLS1_2"
}
resource "azurerm_postgresql_database" "benchmarks_test" {
  name                = "benchmarks_test"
  resource_group_name = azurerm_resource_group.who_ihr_benchmarks.name
  server_name         = azurerm_postgresql_server.who_ihr_benchmarks_db_server.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}
resource "azurerm_private_endpoint" "pend_db01" {
  name                = "pend-db01"
  location            = azurerm_resource_group.who_ihr_benchmarks.location
  resource_group_name = azurerm_resource_group.who_ihr_benchmarks.name
  subnet_id           = azurerm_subnet.build_support_services.id
  private_dns_zone_group {
    name                 = "pdnsz-acr"
    private_dns_zone_ids = [azurerm_private_dns_zone.pdns_acr01.id]
  }
  private_service_connection {
    name                           = "psc-acr"
    private_connection_resource_id = azurerm_container_registry.acr.id
    is_manual_connection           = false
    subresource_names = ["registry"]
  }
}



// 
// - App Service Regional virtual network integration
// - Azure DB Server Private link and Private DNS zone
// - Azure Container Reg Private link (and Private DNS zone?)
//