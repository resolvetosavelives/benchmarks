# This terraform config does more than the WHO one.
# It must setup all the manual configuration that the WHO admins did.
# At the bottom of the file we still load the main module, just like in env/who/main.tf
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.99"
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
#   name        = var.devops_project_name
#   description = "DevOps Project for IHR Benchmarks"
# }
data "azuredevops_project" "project" {
  name = var.devops_project_name
}

data "azurerm_subscription" "current" {
}

resource "azuredevops_serviceendpoint_azurerm" "main" {
  project_id                = data.azuredevops_project.project.id
  service_endpoint_name     = "SC-${var.main_resource_group_name}"
  resource_group            = var.main_resource_group_name
  description               = "Managed by Terraform"
  azurerm_spn_tenantid      = data.azurerm_subscription.current.tenant_id
  azurerm_subscription_id   = data.azurerm_subscription.current.subscription_id
  azurerm_subscription_name = data.azurerm_subscription.current.display_name
}

resource "azuredevops_serviceendpoint_azurerm" "p" {
  project_id                = data.azuredevops_project.project.id
  service_endpoint_name     = "SC-${var.prod_resource_group_name}"
  resource_group            = var.prod_resource_group_name
  description               = "Managed by Terraform"
  azurerm_spn_tenantid      = data.azurerm_subscription.current.tenant_id
  azurerm_subscription_id   = data.azurerm_subscription.current.subscription_id
  azurerm_subscription_name = data.azurerm_subscription.current.display_name
}

resource "azuredevops_serviceendpoint_azurerm" "t" {
  project_id                = data.azuredevops_project.project.id
  service_endpoint_name     = "SC-${var.test_resource_group_name}"
  resource_group            = var.test_resource_group_name
  description               = "Managed by Terraform"
  azurerm_spn_tenantid      = data.azurerm_subscription.current.tenant_id
  azurerm_subscription_id   = data.azurerm_subscription.current.subscription_id
  azurerm_subscription_name = data.azurerm_subscription.current.display_name
}

module "auth_app_staging" {
  source    = "../../modules/auth_app"
  tenant_id = data.azurerm_subscription.current.tenant_id
  name      = "IHR Benchmark (staging)"
  domain    = "${var.organization}-ihrbenchmark-staging.azurewebsites.net"
}

module "auth_app_preview" {
  source    = "../../modules/auth_app"
  tenant_id = data.azurerm_subscription.current.tenant_id
  name      = "IHR Benchmark (preview)"
  domain    = "${var.organization}-ihrbenchmark-preview.azurewebsites.net"
}

module "auth_app_production" {
  source    = "../../modules/auth_app"
  tenant_id = data.azurerm_subscription.current.tenant_id
  name      = "IHR Benchmark"
  domain    = "${var.organization}-ihrbenchmark.azurewebsites.net"
}

module "main" {
  source                               = "../../main"
  organization                         = var.organization
  RAILS_MASTER_KEY                     = var.RAILS_MASTER_KEY
  devops_project_name                  = data.azuredevops_project.project.name
  prod_resource_group_name             = azurerm_resource_group.p.name
  test_resource_group_name             = azurerm_resource_group.t.name
  github_repo_id                       = var.github_repo_id
  github_branch                        = var.github_branch
  github_service_connection_id         = var.github_service_connection_id
  azure_pipelines_yml_path             = var.azure_pipelines_yml_path
  azure_auth_application_id_staging    = module.auth_app_staging.application_id
  azure_auth_application_id_preview    = module.auth_app_preview.application_id
  azure_auth_application_id_production = module.auth_app_production.application_id
  azure_auth_client_secret_staging     = module.auth_app_staging.client_secret
  azure_auth_client_secret_preview     = module.auth_app_preview.client_secret
  azure_auth_client_secret_production  = module.auth_app_production.client_secret
}
