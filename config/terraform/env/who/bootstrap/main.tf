# Bootstrap for running in CCD
# This is here to create the resources in an azure account where we have full permissions.
#
# We can't store the state remotely until we create the resource group where it's stored.
# Rather than solve this cleanly, I expect this to be used very rarely so I will just manually migrate the state.
#
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.74"
    }
  }
}

provider "azurerm" {
  features {}
}

module "bootstrap" {
  source              = "../../../modules/bootstrap"
  resource_group_name = var.tfstate_resource_group_name
}
