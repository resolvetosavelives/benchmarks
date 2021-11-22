#
# with the Basic sku we get less bandwidth, modest performance and storage, and no privacy (could be accessed by public internet if the URL is discovered)
# more info on sku Service tier features and limits: https://docs.microsoft.com/en-us/azure/container-registry/container-registry-skus
#
resource "azurerm_container_registry" "acr" {
  // Azure rules for name: alpha numeric characters, lower case, must be globally unique
  name                          = "whoihrbenchmarksregistry"
  resource_group_name           = local.resource_group_name
  location                      = local.azure_location
  sku                           = "Premium"
  public_network_access_enabled = true
  admin_enabled                 = true
}
resource "azurerm_container_registry_webhook" "acr_webhook_for_app_service" {
  name                = "AcrWebhookForAppService"
  resource_group_name = local.resource_group_name
  location            = local.azure_location
  registry_name       = azurerm_container_registry.acr.name
  # the service_uri is obtained via command:
  #   az webapp deployment container show-cd-url --resource-group <rg name> --name <app name> --slot <slot name>
  # example for sandbox staging slot:
  #   az webapp deployment container show-cd-url --resource-group who-ihr-benchmarks-sandbox --name who-ihr-benchmarks-app-service --slot staging
  # docs on it:
  # - https://docs.microsoft.com/en-us/azure/app-service/deploy-ci-cd-custom-container#automate-with-cli
  # - https://docs.microsoft.com/en-us/cli/azure/webapp/deployment/container#az_webapp_deployment_container_show_cd_url
  service_uri = "https://$who-ihr-benchmarks-app-service__staging:JGxLXj8HmozkqRZT5xti5wEM8inz1q1rqSHeqCZxFosRGyH3hfK1qotgRYFd@who-ihr-benchmarks-app-service-staging.scm.azurewebsites.net/docker/hook"
  status      = "enabled"
  scope       = "benchmarks:latest"
  actions     = ["push"]
  custom_headers = {
    "Content-Type" = "application/json"
  }
}

resource "azurerm_postgresql_server" "who_ihr_benchmarks_db_server" {
  name                          = "psqldb-who-ihr-benchmarks"
  resource_group_name           = local.resource_group_name
  location                      = local.azure_location
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
  resource_group_name = local.resource_group_name
  server_name         = azurerm_postgresql_server.who_ihr_benchmarks_db_server.name
  start_ip_address    = "96.236.208.225"
  end_ip_address      = "96.236.208.225"
}
// it works with this. it is more open than i would like, but it allows access from both  App Service and Devops Pipeline.
resource "azurerm_postgresql_firewall_rule" "db_firewall_rule_for_azure_services" {
  name                = "db-firewall-rule-for-azure-services"
  resource_group_name = local.resource_group_name
  server_name         = azurerm_postgresql_server.who_ihr_benchmarks_db_server.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}
resource "azurerm_postgresql_database" "benchmarks_test" {
  name                = "benchmarks_test" // for build pipeline
  resource_group_name = local.resource_group_name
  server_name         = azurerm_postgresql_server.who_ihr_benchmarks_db_server.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}
resource "azurerm_postgresql_database" "benchmarks_staging" {
  name                = "benchmarks_staging" // for staging instance
  resource_group_name = local.resource_group_name
  server_name         = azurerm_postgresql_server.who_ihr_benchmarks_db_server.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}
