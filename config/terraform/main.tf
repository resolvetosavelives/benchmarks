terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.74"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1.0"
    }
  }
  backend "azurerm" {
    // Variables not allowed in this block
    container_name       = "tfstate"
    resource_group_name  = "IHRBENCHMARK-MAIN-WEU-RG01"
    storage_account_name = "tfstate9e02dada"
    key                  = "terraform.tfstate"
  }
  # backend "azurerm" {
  #   // Variables not allowed in this block
  #   resource_group_name  = "IHRBENCHMARK-MAIN-WEU-RG01"
  #   storage_account_name = "tfstate5b92c0"
  #   container_name       = "tfstate"
  #   key                  = "terraform.tfstate"
  # }
}

provider "azurerm" {
  features {}
}

locals {
  app_name                  = "ihrbenchmark"
  container_repository      = "benchmarks"
  acr_service_endpoint_name = "SC-IHRBENCHMARK-P-ACR-CREDENTIAL"
  # These resource groups are created manually by WHO.
  # If deployed to a non-WHO Azure environment, these must be created manually.
  resource_group_name = terraform.workspace == "production" ? "IHRBENCHMARK-P-WEU-RG01" : "IHRBENCHMARK-T-WEU-RG01"
  # Avoiding the word "production" in scope helps alleviate the confusion of "whoproduction-ihrbenchmark-staging"
  scope = join("", [
    var.ORGANIZATION,
    terraform.workspace == "production" ? "" : terraform.workspace,
  ])
}

data "azurerm_resource_group" "rg" {
  name = local.resource_group_name
}

// to expose to other tf code: id, tenant_id, subscription_id, display_name..
data "azurerm_subscription" "current" {}

module "devops" {
  source                      = "./devops"
  RAILS_MASTER_KEY            = var.RAILS_MASTER_KEY
  resource_group_name         = data.azurerm_resource_group.rg.name
  app_service_name            = azurerm_app_service.app_service.name
  acr_service_endpoint_name   = local.acr_service_endpoint_name
  container_registry_domain   = azurerm_container_registry.acr.login_server
  container_registry_username = azurerm_container_registry.acr.admin_username
  container_registry_password = azurerm_container_registry.acr.admin_password
  container_repository        = local.container_repository
}
