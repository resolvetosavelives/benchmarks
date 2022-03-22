# This terraform config does more than the WHO one.
# It must setup all the manual configuration that the WHO admins did.
# At the bottom of the file we still load the main module, just like in env/who/main.tf
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.93"
    }
  }

  backend "azurerm" {
    // Variables not allowed in this block
    container_name       = "tfstate"
    resource_group_name  = "IHRBENCHMARK-MAIN-WEU-RG01"
    storage_account_name = "tfstatej7z3lg4l"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

module "main" {
  source                   = "../../main"
  organization_prefix      = var.organization_prefix
  devops_project_name      = var.devops_project_name
  prod_resource_group_name = var.prod_resource_group_name
  test_resource_group_name = var.test_resource_group_name
}
