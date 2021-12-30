#// NB: this TerraformState is used for terraform's state storage, and so it stores state
#//   for any/all workspaces terraform is aware of, e.g. sandbox vs production.
#//   Because of this, it is being stored
#resource "azurerm_storage_account" "TerraformState" {
#  // the "5b92c0" part of this is a 6-char portion of output of: rake secret
#  name                     = "tfstate5b92c0"
#  resource_group_name      = local.rg_for_tf_state
#  location                 = local.azure_location
#  account_tier             = "Standard"
#  account_replication_type = "LRS"
#  allow_blob_public_access = true
#}
#
#resource "azurerm_storage_container" "TerraformState" {
#  name                  = "tfstate"
#  storage_account_name  = azurerm_storage_account.TerraformState.name
#  container_access_type = "blob"
#}
