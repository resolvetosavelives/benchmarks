terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }

  required_version = ">= 0.14.9"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "WhoIhrBenchmarks" {
  name     = "WhoIhrBenchmarks"
  location = "westus2"
}

resource "azurerm_postgresql_server" "WhoIhrBenchmarksDbServer" {
  name                = "who-ihr-benchmarks-db-server"
  location            = azurerm_resource_group.WhoIhrBenchmarks.location
  resource_group_name = azurerm_resource_group.WhoIhrBenchmarks.name

  sku_name = "B_Gen5_2"

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
}

resource "azurerm_postgresql_database" "benchmarks_production" {
  name                = "benchmarks_production"
  resource_group_name = azurerm_resource_group.WhoIhrBenchmarks.name
  server_name         = azurerm_postgresql_server.WhoIhrBenchmarksDbServer.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

resource "azurerm_container_registry" "acr" {
  name                     = "WhoIhrBenchmarksRegistry"
  resource_group_name      = azurerm_resource_group.WhoIhrBenchmarks.name
  location                 = azurerm_resource_group.WhoIhrBenchmarks.location
  sku                      = "Basic"
  admin_enabled            = false
}
