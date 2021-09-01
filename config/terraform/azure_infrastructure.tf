#
# with the Basic sku we get less bandwidth, modest performance and storage, and no privacy (could be accessed by public internet if the URL is discovered)
# more info on sku Service tier features and limits: https://docs.microsoft.com/en-us/azure/container-registry/container-registry-skus
#
resource "azurerm_container_registry" "acr" {
  // Azure rules for name: alpha numeric characters only are allowed, lower case, must be globally unique
  name                     = "whoihrbenchmarksregistry"
  resource_group_name      = azurerm_resource_group.who_ihr_benchmarks.name
  location                 = azurerm_resource_group.who_ihr_benchmarks.location
  sku                      = "Premium"
  admin_enabled            = true
  public_network_access_enabled = true
//  network_rule_set {
//    default_action = "Allow"
//    default_action = "Deny"
//    ip_rule {
//      action = "Allow"
//      ip_range = "71.182.150.16/32"
//    }
//  }
}
//resource "azurerm_private_endpoint" "acr" {
//  name                = "pend-acr"
//  location            = azurerm_resource_group.who_ihr_benchmarks.location
//  resource_group_name = azurerm_resource_group.who_ihr_benchmarks.name
//  subnet_id           = azurerm_subnet.build_support_services.id
//  private_dns_zone_group {
//    name                 = "pdnsz-acr"
//    private_dns_zone_ids = [azurerm_private_dns_zone.pdns_acr01.id]
//  }
//  private_service_connection {
//    name                           = "psc-acr"
//    private_connection_resource_id = azurerm_container_registry.acr.id
//    is_manual_connection           = false
//    subresource_names = ["registry"]
//  }
//}
// As of Sunday 3:20pm ET
// REGISTRY_PRIVATE_IP: 10.1.2.5
// DATA_ENDPOINT_PRIVATE_IP: 10.1.2.4
// whoihrbenchmarks.azurecr.io :: whoihrbenchmarks.eastus2.data.azurecr.io

resource "azurerm_postgresql_server" "who_ihr_benchmarks_db_server" {
  name                = "psqldb-who-ihr-benchmarks"
  location            = azurerm_resource_group.who_ihr_benchmarks.location
  resource_group_name = azurerm_resource_group.who_ihr_benchmarks.name
  public_network_access_enabled = false
  // SKUs
  // - GP_Gen5_2 means "General Purpose (more than Basic), Generation 5 (current), 2 cores.
  // - B_Gen5_2 means "Basic (lowest tier), Generation 5 (current), 2 cores.
  // Azure requires a General Purpose tier level to make use of Service Endpoints or Private Link.
  sku_name = "GP_Gen5_2"

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
resource "azurerm_private_dns_zone" "pdns_db01" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.who_ihr_benchmarks.name
}
resource "azurerm_private_dns_zone_virtual_network_link" "pdnslink_db01_primary" {
  name                  = "pdnslink-db01-primary"
  resource_group_name   = azurerm_resource_group.who_ihr_benchmarks.name
  private_dns_zone_name = azurerm_private_dns_zone.pdns_db01.name
  virtual_network_id    = azurerm_virtual_network.primary.id
}
// private endpoint makes a private IP. at 2021-09-01 1:50am ET IP was: 10.0.3.4
resource "azurerm_private_endpoint" "pend_db01" {
  name                = "pend-db01"
  location            = azurerm_resource_group.who_ihr_benchmarks.location
  resource_group_name = azurerm_resource_group.who_ihr_benchmarks.name
  subnet_id           = azurerm_subnet.app_critical_services.id
  private_dns_zone_group {
    name                 = "pdnsz-db01"
    private_dns_zone_ids = [azurerm_private_dns_zone.pdns_db01.id]
  }
  private_service_connection {
    name                           = "psc-db01"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_postgresql_server.who_ihr_benchmarks_db_server.id
    subresource_names = ["postgresqlServer"]
  }
}
