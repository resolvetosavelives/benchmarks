# Output the values necessary for configuring azurerm state backend
#
# backend "azurerm" {
#   resource_group_name  = resource_group_name
#   storage_account_name = storage_account_name
#   container_name       = container_name
#   key                  = "terraform.tfstate"
# }

output "resource_group_name" {
  value       = module.bootstrap.resource_group_name
  description = "tfstate resource group name"
}

output "storage_account_name" {
  value       = module.bootstrap.storage_account_name
  description = "tfstate storage account name"
}

output "container_name" {
  value       = module.bootstrap.container_name
  description = "tfstate blob storage container name"
}

# This access key can be loaded directly as `access_key` in the backend config
# but if you are logged in on `az` you don't need the access key.
#
# This can also be loaded from the command line if we find we need it.
#
#     export ARM_ACCESS_KEY=$(az storage account keys list --resource-group <resource_group> --account-name <storage_account_name> --query '[0].value' -o tsv)
#
# output "access_key" {
#   value       = azurerm_storage_account.tfstate_account.primary_access_key
#   description = "Storage access key should be set to the environment variable ARM_ACCESS_KEY"
#   sensitive   = true
# }

output "variable_group_name" {
  value       = module.bootstrap_devops.variable_group_name
  description = "Name of the variable group to include in azure-pipelines.yml"
}
