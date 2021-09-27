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
  admin_enabled                 = true
  public_network_access_enabled = true
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
  administrator_login              = "fyxzCNQUqNrd"
  administrator_login_password     = "Lo4YdiJcggrN9TfPagCW2AsMtFbQ8R6N"
  version                          = "11"
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"
}
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
