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
    resource_group_name  = "WHOIHRBENCHMARKS-TERRAFORM-EUW-RG01"
    storage_account_name = "tfstate5b92c0"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = "974ebced-5bea-4fa8-af6f-7064aa3eccff"
  tenant_id       = "f610c0b7-bd24-4b39-810b-3dc280afb590"
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
  subscription_name   = "IHRBENCHMARK IHR Benchmarks Capacity application hosting"
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
}
