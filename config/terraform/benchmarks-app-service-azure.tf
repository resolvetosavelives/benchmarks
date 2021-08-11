terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
    azuredevops = {
      source = "microsoft/azuredevops"
      version = ">=0.1.0"
    }
  }
}


provider "azurerm" {
  features {}
  subscription_id = "89789ead-0e38-4e72-8fd9-3cdcbe80b4ef"
}
provider "azuredevops" {}

# 
# SECTION: the baseline infrastructure needed
#
resource "azurerm_resource_group" "WhoIhrBenchmarks" {
  name     = "WhoIhrBenchmarks"
  location = "westus2"
  # later we will use location = "West Europe"
}

resource "azurerm_postgresql_server" "WhoIhrBenchmarksDbServer" {
  name                = "who-ihr-benchmarks-db-server"
  location            = azurerm_resource_group.WhoIhrBenchmarks.location
  resource_group_name = azurerm_resource_group.WhoIhrBenchmarks.name
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
resource "azurerm_postgresql_firewall_rule" "WhoIhrBenchmarksDbServerFirewallRuleAllowAzure" {
  name                = "allow-access-from-azure-services"
  resource_group_name = azurerm_resource_group.WhoIhrBenchmarks.name
  server_name         = azurerm_postgresql_server.WhoIhrBenchmarksDbServer.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}
resource "azurerm_postgresql_firewall_rule" "WhoIhrBenchmarksDbServerFirewallRuleAllowGregHome" {
  name                = "allow-access-from-greg-home"
  resource_group_name = azurerm_resource_group.WhoIhrBenchmarks.name
  server_name         = azurerm_postgresql_server.WhoIhrBenchmarksDbServer.name
  start_ip_address    = "71.182.150.16"
  end_ip_address      = "71.182.150.16"
}
resource "azurerm_postgresql_firewall_rule" "WhoIhrBenchmarksDbServerFirewallRuleAllowAll" {
  name                = "allow-access-from-all"
  resource_group_name = azurerm_resource_group.WhoIhrBenchmarks.name
  server_name         = azurerm_postgresql_server.WhoIhrBenchmarksDbServer.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}
resource "azurerm_postgresql_database" "benchmarks_test" {
  name                = "benchmarks_test"
  resource_group_name = azurerm_resource_group.WhoIhrBenchmarks.name
  server_name         = azurerm_postgresql_server.WhoIhrBenchmarksDbServer.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

#
# with the Basic sku we get less bandwidth, modest performance and storage, and no privacy (could be accessed by public internet if the URL is discovered)
# more info on sku Service tier features and limits: https://docs.microsoft.com/en-us/azure/container-registry/container-registry-skus
#
resource "azurerm_container_registry" "acr" {
  name                     = "WhoIhrBenchmarksRegistry"
  resource_group_name      = azurerm_resource_group.WhoIhrBenchmarks.name
  location                 = azurerm_resource_group.WhoIhrBenchmarks.location
  sku                      = "Basic"
  admin_enabled            = true
}


#
# SECTION: the cloud applications that depend upon the infrastructure
#
variable "GITHUB_AUTH_PERSONAL" {
  type = string
}
variable "DB_HOST" {
  type = string
}
variable "DB_NAME" {
  type = string
}
variable "DB_USER" {
  type = string
}
variable "DB_PASS" {
  type = string
}
resource "azuredevops_project" "project" {
  name = "WhoIhrBenchmarks001"
  description = "WHO IHR Benchmarks Project"
  visibility         = "private"
  version_control    = "Git"
  work_item_template = "Agile"
}

resource "azuredevops_git_repository" "repository" {
  project_id = azuredevops_project.project.id
  name       = "WHO IHR Benchmarks"
  initialization {
    init_type   = "Import"
    source_type = "Git"
    source_url  = "https://github.com/resolvetosavelives/benchmarks.git"
  }
}

resource "azuredevops_serviceendpoint_github" "serviceendpoint_gh_1" {
  project_id = azuredevops_project.project.id
  service_endpoint_name = "Benchmarks GitHub repo"
  # this is a real Personal access tokens to Github that expires in 90 days
  auth_personal {
    personal_access_token = var.GITHUB_AUTH_PERSONAL
  }
}

// build_definition this is what devops.azure.com calls a pipeline
resource "azuredevops_build_definition" "build_definition" {
  project_id = azuredevops_project.project.id
  name       = "Pipeline for Staging Build, Test, and Deploy 001"

  ci_trigger {
    use_yaml = true
  }

  repository {
    repo_type   = "GitHub"
    repo_id     = "resolvetosavelives/benchmarks"
    branch_name = "pipeline-create-and-setup--178993699--build"
    yml_path    = "azure-pipelines.yml"
    service_connection_id = azuredevops_serviceendpoint_github.serviceendpoint_gh_1.id
  }

  variable {
    name = "DB_HOST"
    value = var.DB_HOST
  }
  variable {
    name = "DB_NAME"
    value = var.DB_NAME
  }
  variable {
    name = "DB_USER"
    value = var.DB_USER
  }
  variable {
    name = "DB_PASS"
    value = var.DB_PASS
  }
}
