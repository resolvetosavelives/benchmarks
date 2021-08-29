#
# with the Basic sku we get less bandwidth, modest performance and storage, and no privacy (could be accessed by public internet if the URL is discovered)
# more info on sku Service tier features and limits: https://docs.microsoft.com/en-us/azure/container-registry/container-registry-skus
#
//resource "azurerm_container_registry" "acr" {
//  name                     = "acr"
//  resource_group_name      = azurerm_resource_group.who_ihr_benchmarks.name
//  location                 = azurerm_resource_group.who_ihr_benchmarks.location
//  sku                      = "Premium"
//  admin_enabled            = true
//  public_network_access_enabled = false
//  network_rule_set {
//    virtual_network {
//      subnet_id = azurerm_subnet.subnet_for_build_support_services.id
//    }
//  }
//}
//
//resource "azurerm_postgresql_server" "who_ihr_benchmarks_db_server" {
//  name                = "db-server"
//  location            = azurerm_resource_group.who_ihr_benchmarks.location
//  resource_group_name = azurerm_resource_group.who_ihr_benchmarks.name
//  sku_name = "B_Gen5_2" // or B_Gen5_1
//
//  storage_mb                   = 5120
//  backup_retention_days        = 7
//  geo_redundant_backup_enabled = false
//  auto_grow_enabled            = true
//
//  # these wont be real credentials once this is working but for now these are good enough during development
//  # TODO: remove these fake credentials and replace with using a secret store
//  administrator_login          = "fyxzCNQUqNrd"
//  administrator_login_password = "Lo4YdiJcggrN9TfPagCW2AsMtFbQ8R6N"
//  version                      = "11"
//  ssl_enforcement_enabled      = true
//  ssl_minimal_tls_version_enforced = "TLS1_2"
//}
//resource "azurerm_postgresql_database" "benchmarks_test" {
//  name                = "benchmarks_test"
//  resource_group_name = azurerm_resource_group.who_ihr_benchmarks.name
//  server_name         = azurerm_postgresql_server.who_ihr_benchmarks_db_server.name
//  charset             = "UTF8"
//  collation           = "English_United States.1252"
//}



// 
// - App Service Regional virtual network integration
// - Azure DB Server Private link and Private DNS zone
// - Azure Container Reg Private link (and Private DNS zone?)
//