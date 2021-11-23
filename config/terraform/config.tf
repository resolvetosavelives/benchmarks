terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.74"
    }
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = ">= 0.1.7"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1.0"
    }
  }
  // terraform state stored securely in azure storage and is encrypted in transit and at rest.
  backend "azurerm" {
    // Variables not allowed in this block
    resource_group_name  = "who-ihr-benchmarks-terraform"
    storage_account_name = "tfstate5b92c0"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = "89789ead-0e38-4e72-8fd9-3cdcbe80b4ef"
  tenant_id       = "7018baf0-4beb-46d2-a7d1-7679026af9e0"
}
// to expose to other tf code: id, tenant_id, subscription_id, display_name..
data "azurerm_subscription" "current" {}

//
// See the README.md file for the conventions for naming things and code style.
//
locals {
  env                 = terraform.workspace == "production" ? "production" : "sandbox"
  app_name            = "who-ihr-benchmarks"
  resource_group_name = "${local.app_name}-${local.env}"
  subscription_name   = "Gregs Azure for experimentation on CloudCity work"
  # FIXME: WHO requires use of North or West Europe Azure regions
  azure_location = "eastus2"
}

resource "random_string" "db_administrator_login" {
  length  = 10
  special = false
}
resource "random_password" "db_administrator_password" {
  length  = 20
  special = true
}
