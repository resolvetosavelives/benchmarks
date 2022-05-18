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
    storage_account_name = "tfstate9e02dada"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

module "main" {
  source                               = "../../main"
  organization                         = var.organization
  RAILS_MASTER_KEY                     = var.RAILS_MASTER_KEY
  devops_project_name                  = var.devops_project_name
  prod_resource_group_name             = var.prod_resource_group_name
  test_resource_group_name             = var.test_resource_group_name
  github_repo_id                       = var.github_repo_id
  github_branch                        = var.github_branch
  github_service_connection_id         = var.github_service_connection_id
  azure_pipelines_yml_path             = var.azure_pipelines_yml_path
  azure_auth_application_id_staging    = var.azure_auth_application_id_staging
  azure_auth_application_id_preview    = var.azure_auth_application_id_preview
  azure_auth_application_id_production = var.azure_auth_application_id_production
  azure_auth_client_secret_staging     = var.azure_auth_client_secret_staging
  azure_auth_client_secret_preview     = var.azure_auth_client_secret_preview
  azure_auth_client_secret_production  = var.azure_auth_client_secret_production
}
