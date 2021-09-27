#
# with the Basic sku we get less bandwidth, modest performance and storage, and no privacy (could be accessed by public internet if the URL is discovered)
# more info on sku Service tier features and limits: https://docs.microsoft.com/en-us/azure/container-registry/container-registry-skus
#
resource "azurerm_container_registry" "acr" {
  // Azure rules for name: alpha numeric characters, lower case, must be globally unique
  name                          = "whoihrbenchmarksregistry"
  resource_group_name           = azurerm_resource_group.who_ihr_benchmarks.name
  location                      = azurerm_resource_group.who_ihr_benchmarks.location
  sku                           = "Premium"
  public_network_access_enabled = true
  admin_enabled                 = true
}

resource "azurerm_postgresql_server" "who_ihr_benchmarks_db_server" {
  name                          = "psqldb-who-ihr-benchmarks"
  location                      = azurerm_resource_group.who_ihr_benchmarks.location
  resource_group_name           = azurerm_resource_group.who_ihr_benchmarks.name
  public_network_access_enabled = true
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
  administrator_login              = "eAb136b1eE"
  administrator_login_password     = "4eD90c39fCd3cAd26e78"
  version                          = "11"
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"
}
resource "azurerm_postgresql_firewall_rule" "db_firewall_rule_for_greg_home" {
  name                = "db-firewall-rule-for-greg-home"
  resource_group_name = azurerm_resource_group.who_ihr_benchmarks.name
  server_name         = azurerm_postgresql_server.who_ihr_benchmarks_db_server.name
  start_ip_address    = "71.182.150.16"
  end_ip_address      = "71.182.150.16"
}
resource "azurerm_sql_virtual_network_rule" "psql_vnet_rule" {
  name                                 = "psql-vnet-rule"
  resource_group_name                  = azurerm_resource_group.who_ihr_benchmarks.name
  server_name                          = azurerm_postgresql_server.who_ihr_benchmarks_db_server.name
  subnet_id                            = azurerm_subnet.app_critical_services.id
}
// outbound_ip_addresses OR outbound_ip_address_list
// 52.252.22.155,20.62.18.64,52.179.234.0,52.179.234.1,52.179.237.99,52.179.237.148,52.252.23.246,52.253.64.47,52.253.64.124,52.253.64.125,52.253.65.84,52.253.65.85,52.254.103.240,52.253.65.92,52.253.65.93,52.177.89.135,52.253.69.207,52.253.69.240,52.167.19.211,52.177.147.229,40.65.238.53,52.177.147.249,20.44.83.102,52.177.148.19,20.49.97.17
resource "azurerm_postgresql_database" "benchmarks_test" {
  name                = "benchmarks_test" // for build pipeline
  resource_group_name = azurerm_resource_group.who_ihr_benchmarks.name
  server_name         = azurerm_postgresql_server.who_ihr_benchmarks_db_server.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}
resource "azurerm_postgresql_database" "benchmarks_staging" {
  name                = "benchmarks_staging" // for staging instance
  resource_group_name = azurerm_resource_group.who_ihr_benchmarks.name
  server_name         = azurerm_postgresql_server.who_ihr_benchmarks_db_server.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}
