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
      version = "~> 2.93"
    }

    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "~> 0.2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# In the WHO account, this is manually created for us
# Here we must create it ourselves.
resource "azurerm_resource_group" "main" {
  name     = var.main_resource_group_name
  location = var.location
}

resource "azurerm_resource_group" "p" {
  name     = var.prod_resource_group_name
  location = var.location
}

resource "azurerm_resource_group" "t" {
  name     = var.test_resource_group_name
  location = var.location
}

# I had trouble creating this automatically.
# resource "azuredevops_project" "project" {
#   name        = local.devops_project_name
#   description = "DevOps Project for IHR Benchmarks"
# }
data "azuredevops_project" "project" {
  name = var.devops_project_name
}

data "azurerm_subscription" "current" {}

# resource "azuredevops_serviceendpoint_azurerm" "main" {
#   project_id            = data.azuredevops_project.project.id
#   service_endpoint_name = "SC-IHRBENCHMARK-MAIN-WEU-RG01"
#   description           = "Managed by Terraform bootstrap-manual"
#   credentials {
#     serviceprincipalid  = "59f5508d-eac2-40a3-946c-db6d21d4670d"  # application ID
#     serviceprincipalkey = "nwO7Q~R5X4GX~qsYnpl04_z_NKNRaqVx6mjoM" # client id "value"
#   }
#   azurerm_spn_tenantid      = data.azurerm_subscription.current.tenant_id
#   azurerm_subscription_id   = data.azurerm_subscription.current.subscription_id
#   azurerm_subscription_name = data.azurerm_subscription.current.display_name
# }

resource "azuredevops_serviceendpoint_azurerm" "p" {
  project_id            = data.azuredevops_project.project.id
  service_endpoint_name = "SC-IHRBENCHMARK-P-WEU-RG01"
  description           = "Managed by Terraform bootstrap-manual"
  credentials {
    serviceprincipalid  = "59f5508d-eac2-40a3-946c-db6d21d4670d"  # application ID
    serviceprincipalkey = "nwO7Q~R5X4GX~qsYnpl04_z_NKNRaqVx6mjoM" # client id "value"
  }
  azurerm_spn_tenantid      = data.azurerm_subscription.current.tenant_id
  azurerm_subscription_id   = data.azurerm_subscription.current.subscription_id
  azurerm_subscription_name = data.azurerm_subscription.current.display_name
}

# resource "azuredevops_serviceendpoint_azurerm" "t" {
#   project_id                = data.azuredevops_project.project.id
#   service_endpoint_name     = "SC-IHRBENCHMARK-T-WEU-RG01"
#   description               = "Managed by Terraform bootstrap-manual"
#   credentials {
#     serviceprincipalid  = "59f5508d-eac2-40a3-946c-db6d21d4670d"  # application ID
#     serviceprincipalkey = "nwO7Q~R5X4GX~qsYnpl04_z_NKNRaqVx6mjoM" # client id "value"
#   }
#   azurerm_spn_tenantid      = data.azurerm_subscription.current.tenant_id
#   azurerm_subscription_id   = data.azurerm_subscription.current.subscription_id
#   azurerm_subscription_name = data.azurerm_subscription.current.display_name
# }

module "bootstrap" {
  source              = "../../../modules/bootstrap"
  resource_group_name = azurerm_resource_group.main.name
}

module "bootstrap_devops" {
  source                         = "../../../modules/bootstrap_devops"
  RAILS_MASTER_KEY               = var.RAILS_MASTER_KEY
  organization_prefix            = var.organization_prefix
  location                       = var.location
  devops_project_name            = var.devops_project_name
  github_repo_id                 = var.github_repo_id
  github_branch                  = var.github_branch
  github_service_connection_id   = var.github_service_connection_id
  azure_pipelines_yml_path       = var.azure_pipelines_yml_path
  terraform_resource_group_name  = module.bootstrap.resource_group_name
  terraform_storage_account_name = module.bootstrap.storage_account_name
  terraform_container_name       = module.bootstrap.container_name
}

