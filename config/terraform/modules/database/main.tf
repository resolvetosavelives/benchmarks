terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.24.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1.0"
    }
  }
}

locals {
  database_fqdn        = var.fqdn
  database_server_name = "${var.namespace}-postgresql"
  database_url_without_db_name = join("", [
    "postgres://",
    azurerm_postgresql_server.db.administrator_login,
    urlencode("@"),
    azurerm_postgresql_server.db.name,
    ":",
    azurerm_postgresql_server.db.administrator_login_password,
    "@",
    local.database_fqdn,
    ":5432/",
  ])
  database_url = join("", [
    local.database_url_without_db_name,
    azurerm_postgresql_database.db.name,
    "?sslmode=require",
  ])
}

resource "random_string" "db_administrator_login" {
  length  = 10
  special = false
  lower   = true
  upper   = false
  numeric = false
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
  resource_group_name           = var.resource_group_name
  location                      = var.location
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

  administrator_login              = random_string.db_administrator_login.result
  administrator_login_password     = random_password.db_administrator_password.result
  version                          = "11"
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"
}

resource "azurerm_postgresql_firewall_rule" "db_firewall_rules" {
  for_each            = var.developer_ips
  name                = "db-firewall-rule-${each.key}"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_server.db.name
  start_ip_address    = each.value
  end_ip_address      = each.value
}

resource "azurerm_postgresql_firewall_rule" "db_firewall_rule_for_azure_services" {
  name                = "db-firewall-rule-for-azure-services"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_server.db.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

resource "azurerm_postgresql_database" "db" {
  name                = var.database_name
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_server.db.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}
