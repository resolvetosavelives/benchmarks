terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.99"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1.0"
    }
  }
}

locals {
  database_server_name = "${var.namespace}-postgresql"
  database_url_without_db_name = join("", [
    "postgres://",
    azurerm_postgresql_server.db.administrator_login,
    urlencode("@"),
    azurerm_postgresql_server.db.name,
    ":",
    azurerm_postgresql_server.db.administrator_login_password,
    "@",
    azurerm_postgresql_server.db.fqdn,
    ":5432/",
  ])
  staging_database_url = join("", [
    local.database_url_without_db_name,
    azurerm_postgresql_database.benchmarks_staging.name,
    "?sslmode=require",
  ])
  production_database_url = join("", [
    local.database_url_without_db_name,
    azurerm_postgresql_database.benchmarks_production.name,
    "?sslmode=require",
  ])
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "random_string" "db_administrator_login" {
  length  = 10
  special = false
  lower   = true
  upper   = false
  keepers = {
    database_server_name = local.database_server_name
  }
}
resource "random_password" "db_administrator_password" {
  length  = 20
  special = true
  # this will be used in DATABASE_URL so we want only URL-friendly special chars
  override_special = "$-_="
  keepers = {
    database_server_name = local.database_server_name
  }
}
resource "azurerm_postgresql_server" "db" {
  name                          = local.database_server_name
  resource_group_name           = data.azurerm_resource_group.rg.name
  location                      = data.azurerm_resource_group.rg.location
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

  administrator_login              = random_string.db_administrator_login.result
  administrator_login_password     = random_password.db_administrator_password.result
  version                          = "11"
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"
}

resource "azurerm_postgresql_firewall_rule" "db_firewall_rule_for_greg_home" {
  name                = "db-firewall-rule-for-greg-home"
  resource_group_name = data.azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_server.db.name
  start_ip_address    = "96.236.208.225"
  end_ip_address      = "96.236.208.225"
}

resource "azurerm_postgresql_firewall_rule" "db_firewall_rule_for_martin_home" {
  name                = "db-firewall-rule-for-martin-home"
  resource_group_name = data.azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_server.db.name
  start_ip_address    = "73.12.247.86"
  end_ip_address      = "73.12.247.86"
}
// Allow from Azure. it is more open than i would like, but it works for both App Service and Devops Pipeline.
resource "azurerm_postgresql_firewall_rule" "db_firewall_rule_for_azure_services" {
  name                = "db-firewall-rule-for-azure-services"
  resource_group_name = data.azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_server.db.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}
resource "azurerm_postgresql_database" "benchmarks_staging" {
  name                = "benchmarks_staging"
  resource_group_name = data.azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_server.db.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}
resource "azurerm_postgresql_database" "benchmarks_production" {
  name                = "benchmarks_production"
  resource_group_name = data.azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_server.db.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}
