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
#  backend "azurerm" {
#    // Variables not allowed in this block
#    resource_group_name  = "WHOIHRBENCHMARKS-TERRAFORM-EUW-RG01"
#    storage_account_name = "tfstate5b92c0"
#    container_name       = "tfstate"
#    key                  = "terraform.tfstate"
#  }
}

provider "azurerm" {
  features {}
#  # WHO sub and tenant
#  subscription_id = "974ebced-5bea-4fa8-af6f-7064aa3eccff"
#  tenant_id       = "f610c0b7-bd24-4b39-810b-3dc280afb590"
  # my personal sub and tenant
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
  app_name            = "whoihrbenchmarks"
  resource_group_name = "${local.app_name}-${local.env}"
#  # WHO sub name
#  subscription_name   = "IHRBENCHMARK IHR Benchmarks Capacity application hosting"
  # my personal sub name
  subscription_name   = "Gregs Azure for experimentation on CloudCity work"
  azure_location      = "westeurope"
  rg_for_workspace    = terraform.workspace == "production" ? upper("${local.app_name}-production-EUW-RG01") : upper("${local.app_name}-sandbox-EUW-RG01")
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
