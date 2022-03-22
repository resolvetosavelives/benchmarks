# This terraform config does more than the WHO one.
# It must setup all the manual configuration that the WHO admins did.
# At the bottom of the file we still load the main module, just like in env/who/main.tf
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

data "azurerm_subscription" "current" {
}

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

module "main" {
  source                   = "../../main"
  organization_prefix      = "ccd"
  RAILS_MASTER_KEY         = var.RAILS_MASTER_KEY
  devops_project_name      = data.azuredevops_project.project.name
  prod_resource_group_name = azurerm_resource_group.p.name
  test_resource_group_name = azurerm_resource_group.t.name
}
