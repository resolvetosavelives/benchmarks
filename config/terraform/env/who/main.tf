terraform {
  required_version = "~> 1.3"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.24.0"
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
    storage_account_name = "tfstate9e02dada"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "prod" {
  name = var.prod_resource_group_name
}

data "azurerm_resource_group" "uat" {
  name = var.test_resource_group_name
}

module "main" {
  source                               = "../../main"
  organization                         = var.organization
  devops_project_id                    = var.devops_project_id
  prod_resource_group_name             = var.prod_resource_group_name
  test_resource_group_name             = var.test_resource_group_name
  location                             = var.location
  github_repo_id                       = var.github_repo_id
  github_branch                        = var.github_branch
  github_service_connection_id         = var.github_service_connection_id
  azure_pipelines_yml_path             = var.azure_pipelines_yml_path
  azure_auth_application_id_staging    = var.azure_auth_application_id_staging
  azure_auth_application_id_production = var.azure_auth_application_id_production
  azure_auth_client_secret_staging     = var.azure_auth_client_secret_staging
  azure_auth_client_secret_production  = var.azure_auth_client_secret_production
  avo_license_key                      = var.avo_license_key
  avo_license_key_uat                  = var.avo_license_key_uat
  ci_agent_public_key                  = var.ci_agent_public_key
  github_pat                           = var.github_pat
  github_pat_expiry                    = var.github_pat_expiry
  domain_name                          = var.domain_name
  uat_domain_name                      = var.uat_domain_name
  admin_email_uat                      = var.admin_email_uat
  admin_email_prod                     = var.admin_email_prod
  app_settings = {
    RAILS_MASTER_KEY = var.RAILS_MASTER_KEY
    AZURE_TENANT_ID  = var.tenant_id
    EMAIL_FROM       = var.email_from
  }
  developer_group  = var.developer_group
  prod_tags        = data.azurerm_resource_group.prod.tags
  uat_tags         = data.azurerm_resource_group.uat.tags
  cert_name        = "whointcompletechain" # The name provided to us by the WHO IT team
  create_key_vault = false                 # We use one created by the WHO IT team
  key_vault_name   = "who-external-gw-keyvault"
  sendgrid_api_key = var.sendgrid_api_key
  uat_debug_mode   = var.uat_debug_mode
}
