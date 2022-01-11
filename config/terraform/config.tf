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
  // terraform state stored securely in azure storage and is encrypted in transit and at rest.
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
// to expose to other tf code: id, tenant_id, subscription_id, display_name..
data "azurerm_subscription" "current" {}

//
// See the README.md file for the conventions for naming things and code style.
//
locals {
  env      = terraform.workspace == "production" ? "P" : "T"
  scope    = "${var.ORGANIZATION}${terraform.workspace}"
  app_name = "ihrbenchmark"
  # Used for azuredevops_serviceendpoint_azurecr
  # subscription_name = "Cloud City Azure"
  azure_location = "westeurope"

  registry_name     = "${local.app_name}${local.scope}" # ihrbenchmarkwhoproduction
  registry_domain   = "${local.registry_name}.azurecr.io"
  registry_url      = "https://${local.registry_domain}"
  docker_image_name = "${local.registry_domain}/benchmarks:latest"
  # per WHO Azure project policy, ResourceGroup names are UPPERCASE-WITH-HYPHENS
  rg_for_workspace = upper("${local.app_name}-${local.env}-WEU-RG01")
  # Must match exactly the backend above
  rg_for_terraform = "IHRBENCHMARK-MAIN-WEU-RG01"
}

module "devops" {
  source                                    = "./devops"
  DATABASE_URL                              = var.DATABASE_URL_FOR_PIPELINE
  GITHUB_SERVICE_CONNECTION_ID              = var.DEVOPS_GITHUB_SERVICE_CONNECTION_ID
  DEVOPS_DOCKER_ACR_SERVICE_CONNECTION_NAME = var.DEVOPS_DOCKER_ACR_SERVICE_CONNECTION_NAME
  GITHUB_REPO                               = var.GITHUB_REPO
  GITHUB_BRANCH                             = var.GITHUB_BRANCH
  RAILS_MASTER_KEY                          = var.RAILS_MASTER_KEY
}

resource "random_string" "db_administrator_login" {
  length  = 10
  special = false
}
resource "random_password" "db_administrator_password" {
  length  = 20
  special = true
  # this will be used in DATABASE_URL so we want only URL-friendly special chars
  override_special = "$-_="
}
resource "null_resource" "reveal_db_secret" {
  triggers = {
    earliestRestoreDate_of_the_db_server = "2021-12-01T22:10:27.00+00:00"
    db_server_admin_pwd                  = random_password.db_administrator_password.result
  }
}
