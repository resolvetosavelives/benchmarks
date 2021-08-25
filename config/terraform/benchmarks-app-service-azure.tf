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
  // terraform state stored securely in azure storage and is encrypted in transit and at rest.
  backend "azurerm" {
    resource_group_name = "WhoIhrBenchmarks"
    storage_account_name = "tfstate5b92c0"
    container_name = "tfstate"
    key = "terraform.tfstate"
  }
}


provider "azurerm" {
  features {}
  subscription_id = "89789ead-0e38-4e72-8fd9-3cdcbe80b4ef"
  // tenant_id = "7018baf0-4beb-46d2-a7d1-7679026af9e0
}

provider "azuredevops" {}



#
# Variables used
#
variable "GITHUB_AUTH_PERSONAL" {
  type = string
}
variable "DATABASE_URL" {
  type = string
}
variable "DOCKER_REGISTRY_SERVER_URL" {
  type = string
}
variable "DOCKER_REGISTRY_SERVER_USERNAME" {
  type = string
}
variable "DOCKER_REGISTRY_SERVER_PASSWORD" {
  type = string
}
variable "RAILS_MASTER_KEY" {
  type = string
}



# 
# SECTION: the baseline infrastructure needed
#
resource "azurerm_resource_group" "WhoIhrBenchmarks" {
  name     = "WhoIhrBenchmarks"
  location = "westus2" # prob should switch to East US 2
  # later we will use location = "West Europe"
}

resource "azurerm_storage_account" "TerraformState" {
  // the "5b92c0" part of this is a 6-char portion of output of: rake secret
  name                     = "tfstate5b92c0"
  resource_group_name      = azurerm_resource_group.WhoIhrBenchmarks.name
  location                 = azurerm_resource_group.WhoIhrBenchmarks.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_blob_public_access = true
}

resource "azurerm_storage_container" "TerraformState" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.TerraformState.name
  container_access_type = "blob"
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

resource "azurerm_app_service_plan" "app_service_plan" {
  name                = "who-ihr-benchmarks-app-service-plan"
  location            = azurerm_resource_group.WhoIhrBenchmarks.location
  resource_group_name = azurerm_resource_group.WhoIhrBenchmarks.name
  // these settings "kind" and "reserved" are required by Azure in order to use app_service's
  //   config option linux_fx_version which we need to run Linux containers
  kind                = "Linux"
  reserved            = true
//  reserved            = true # do not need reserved for now
  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "app_service" {
  name                = "who-ihr-benchmarks-app-service"
  location            = azurerm_resource_group.WhoIhrBenchmarks.location
  resource_group_name = azurerm_resource_group.WhoIhrBenchmarks.name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id
//  health_check_path = "/health" # TODO
  identity {
    type = "SystemAssigned"
  }
  site_config {
    linux_fx_version = "DOCKER|whoihrbenchmarksregistry.azurecr.io/benchmarks:latest"
  }
  // not sure if this goes to our app or to App Service layer
  app_settings = {
    DOCKER_REGISTRY_SERVER_URL = var.DOCKER_REGISTRY_SERVER_URL
    DOCKER_REGISTRY_SERVER_USERNAME = var.DOCKER_REGISTRY_SERVER_USERNAME
    DOCKER_REGISTRY_SERVER_PASSWORD = var.DOCKER_REGISTRY_SERVER_PASSWORD
    DATABASE_URL = var.DATABASE_URL
    RAILS_MASTER_KEY = var.RAILS_MASTER_KEY
  }
  logs {
    // http_logs seems to be the Azure App Service-level logs, external to our app
    http_logs {
      file_system {
        retention_in_days = 7
        retention_in_mb = 100
      }
    }
    // application_logs seems to mean logs from our actual app code in its container
    application_logs {
      file_system_level = "Verbose"
    }
  }
}
resource "azurerm_app_service_slot" "benchmarks_staging_slot" {
  name                = "staging"
  location            = azurerm_resource_group.WhoIhrBenchmarks.location
  resource_group_name = azurerm_resource_group.WhoIhrBenchmarks.name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id
  app_service_name    = azurerm_app_service.app_service.name
}


#
# SECTION: the cloud applications that depend upon the infrastructure
#
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
    name = "DATABASE_URL"
    is_secret = true
    secret_value = var.DATABASE_URL
    allow_override = false
  }
}
