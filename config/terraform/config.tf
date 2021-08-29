terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = ">=0.1.0"
    }
  }
  // terraform state stored securely in azure storage and is encrypted in transit and at rest.
  //  backend "azurerm" {
  //    resource_group_name = "who_ihr_benchmarks"
  //    storage_account_name = "tfstate5b92c0"
  //    container_name = "tfstate"
  //    key = "terraform.tfstate"
  //  }
}

provider "azurerm" {
  features {}
  subscription_id = "89789ead-0e38-4e72-8fd9-3cdcbe80b4ef"
  // tenant_id = "7018baf0-4beb-46d2-a7d1-7679026af9e0
}

//
// See the README.md file for the conventions for naming things and code style.
//
locals {
  env      = terraform.workspace == "production" ? "production" : "sandbox"
  app_name = "who-ihr-benchmarks"
  resource_group_name = "${local.app_name}-${local.env}"
//  config_map = {
//    "sandbox" = {
//    }
//    "production" = {
//    }
//  }
}
