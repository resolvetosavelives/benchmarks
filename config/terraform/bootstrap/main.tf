# Provision terraform's own state storage to bootstrap terraform.
# This must be created before we can store the state remotely.
#
# In the WHO azure account, we have the resources group created for us already.
#
# There's no state recorded for this particular storage container.
# You can import if you need to tear down and recreate the state container.
# These commands reference the following env vars in `.env.who`:
# * ARM_SUBSCRIPTION_ID - The subscription id also available from `az account show`
# * TF_VAR_TFSTATE_RESOURCE_GROUP - The manually created resource group ("IHRBENCHMARK-MAIN-WEU-RG01")
# * TF_VAR_TFSTATE_STORAGE_ACCOUNT - The name of the storage account (generated here)
#
#     terraform import azurerm_storage_account.tfstate_account "/subscriptions/$ARM_SUBSCRIPTION_ID/resourceGroups/$TF_VAR_TFSTATE_RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/$TF_VAR_TFSTATE_STORAGE_ACCOUNT"
#     terraform import azurerm_storage_container.tfstate_container "https://$TF_VAR_TFSTATE_STORAGE_ACCOUNT.blob.core.windows.net/tfstate"
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

provider "azurerm" {
  features {}
}

resource "random_id" "account_name" {
  keepers = {
    # Keepers are used to regenerate the random id when this changes.
    # If we move resource groups, we want the id to change.
    resource_group_name = var.TFSTATE_RESOURCE_GROUP
  }
  prefix = "tfstate"

  byte_length = 4
}
data "azurerm_resource_group" "resource_group" {
  name = random_id.account_name.keepers.resource_group_name
}

resource "azurerm_storage_account" "tfstate_account" {
  name                     = random_id.account_name.hex
  resource_group_name      = data.azurerm_resource_group.resource_group.name
  location                 = data.azurerm_resource_group.resource_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "tfstate_container" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.tfstate_account.name
  container_access_type = "private"
}
