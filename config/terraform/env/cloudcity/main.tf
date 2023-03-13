# This terraform config does more than the WHO one.
# It must setup all the manual configuration that the WHO admins did.
# At the bottom of the file we still load the main module, just like in env/who/main.tf
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
    storage_account_name = "tfstatewk0nxl7j"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

resource "azurerm_resource_group" "p" {
  name     = var.prod_resource_group_name
  location = var.location
}

resource "azurerm_resource_group" "t" {
  name     = var.test_resource_group_name
  location = var.location
}

data "azurerm_subscription" "current" {
}

resource "azuredevops_serviceendpoint_azurerm" "main" {
  project_id                = var.devops_project_id
  service_endpoint_name     = "SC-${var.main_resource_group_name}"
  resource_group            = var.main_resource_group_name
  description               = "Managed by Terraform"
  azurerm_spn_tenantid      = data.azurerm_subscription.current.tenant_id
  azurerm_subscription_id   = data.azurerm_subscription.current.subscription_id
  azurerm_subscription_name = data.azurerm_subscription.current.display_name
}

resource "azuredevops_serviceendpoint_azurerm" "p" {
  project_id                = var.devops_project_id
  service_endpoint_name     = "SC-${var.prod_resource_group_name}"
  resource_group            = var.prod_resource_group_name
  description               = "Managed by Terraform"
  azurerm_spn_tenantid      = data.azurerm_subscription.current.tenant_id
  azurerm_subscription_id   = data.azurerm_subscription.current.subscription_id
  azurerm_subscription_name = data.azurerm_subscription.current.display_name
}

resource "azuredevops_serviceendpoint_azurerm" "t" {
  project_id                = var.devops_project_id
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

module "auth_app_production" {
  source    = "../../modules/auth_app"
  tenant_id = data.azurerm_subscription.current.tenant_id
  name      = "IHR Benchmark"
  domain    = "${var.organization}-ihrbenchmark.azurewebsites.net"
}

module "main" {
  source                               = "../../main"
  organization                         = var.organization
  devops_project_id                    = var.devops_project_id
  prod_resource_group_name             = azurerm_resource_group.p.name
  test_resource_group_name             = azurerm_resource_group.t.name
  location                             = var.location
  github_repo_id                       = var.github_repo_id
  github_branch                        = var.github_branch
  github_service_connection_id         = var.github_service_connection_id
  azure_pipelines_yml_path             = var.azure_pipelines_yml_path
  azure_auth_application_id_staging    = module.auth_app_staging.application_id
  azure_auth_application_id_production = module.auth_app_production.application_id
  azure_auth_client_secret_staging     = module.auth_app_staging.client_secret
  azure_auth_client_secret_production  = module.auth_app_production.client_secret
  depends_on                           = [azurerm_resource_group.p]
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
  prod_tags        = azurerm_resource_group.p.tags
  uat_tags         = azurerm_resource_group.t.tags
  create_key_vault = true
  cert_name        = "ccd-ihrbenchmark"
  key_vault_name   = "ccd-ihrbenchmarkkv"
  sendgrid_api_key = var.sendgrid_api_key
}
