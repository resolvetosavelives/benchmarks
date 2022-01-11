# Provision terraform's own state storage to bootstrap terraform.
# This must be created before we can store the state remotely.
#
# In the WHO azure account, we have the resources group created for us already.
#
# There's no state recorded for this particular storage container.
# You can import if you need to tear down and recreate the state container.

# These commands reference the following, some of which is in .env.who
#
# * ARM_SUBSCRIPTION_ID - The subscription id also available from `az account show`
# * TF_VAR_TFSTATE_RESOURCE_GROUP - The existing resource group ("IHRBENCHMARK-MAIN-WEU-RG01")
# * TFSTATE_STORAGE_ACCOUNT_NAME - The name of the storage account (generated here)
#
#     terraform import azurerm_storage_account.tfstate_account "/subscriptions/${ARM_SUBSCRIPTION_ID}/resourceGroups/${TF_VAR_TFSTATE_RESOURCE_GROUP}/providers/Microsoft.Storage/storageAccounts/${TFSTATE_STORAGE_ACCOUNT_NAME}"
#     terraform import azurerm_storage_container.tfstate_container "https://${TFSTATE_STORAGE_ACCOUNT_NAME}.blob.core.windows.net/tfstate"
#
# IMPORTANT: Don't destroy this unless _everything_ in other terraform builds is already destroyed.
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
}

locals {
  key = "tfstate"
}

provider "azurerm" {
  features {}
}

# Using random_password because it's easy to import (unlike random_id)
resource "random_string" "account_name" {
  lower   = true
  special = false
  upper   = false
  length  = 8
  keepers = {
    # Keepers are used to regenerate the random string when this value changes.
    # If we move resource groups, we want the id to change so we don't conflict.
    resource_group_name = var.TFSTATE_RESOURCE_GROUP
  }
}
data "azurerm_resource_group" "resource_group" {
  # Accessing "through" the random_string ensures we use the same value.
  name = random_string.account_name.keepers.resource_group_name
}

resource "azurerm_storage_account" "tfstate_account" {
  name                     = "${local.key}${random_string.account_name.result}"
  resource_group_name      = data.azurerm_resource_group.resource_group.name
  location                 = data.azurerm_resource_group.resource_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "tfstate_container" {
  name                  = local.key
  storage_account_name  = azurerm_storage_account.tfstate_account.name
  container_access_type = "private"
}
