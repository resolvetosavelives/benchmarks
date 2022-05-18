terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.93"
    }
  }
}

locals {
  app_name             = "ihrbenchmark"
  container_repository = "benchmarks"
  # These resource groups are created manually by WHO.
  # If deployed to a non-WHO Azure environment, these must be created manually.
  resource_group_name = terraform.workspace == "production" ? var.prod_resource_group_name : var.test_resource_group_name
  # Avoiding the word "production" in scope helps alleviate the confusion of "whoproduction-ihrbenchmark-staging"
  scope = join("", [
    var.organization,
    terraform.workspace == "production" ? "" : terraform.workspace,
  ])
  scoped_app_name = "${local.scope}-${local.app_name}"
}

data "azurerm_subscription" "current" {}

module "database" {
  source              = "../modules/database"
  resource_group_name = local.resource_group_name
  namespace           = local.scoped_app_name
}

module "application" {
  source                               = "../modules/application"
  resource_group_name                  = local.resource_group_name
  app_service_name                     = local.scoped_app_name
  staging_database_url                 = module.database.staging_database_url
  production_database_url              = module.database.production_database_url
  container_repository                 = local.container_repository
  RAILS_MASTER_KEY                     = var.RAILS_MASTER_KEY
  azure_auth_application_id_staging    = var.azure_auth_application_id_staging
  azure_auth_application_id_preview    = var.azure_auth_application_id_preview
  azure_auth_application_id_production = var.azure_auth_application_id_production
  azure_auth_client_secret_staging     = var.azure_auth_client_secret_staging
  azure_auth_client_secret_preview     = var.azure_auth_client_secret_preview
  azure_auth_client_secret_production  = var.azure_auth_client_secret_production
}

module "devops" {
  source                       = "../modules/devops"
  devops_project_name          = var.devops_project_name
  resource_group_name          = local.resource_group_name
  app_service_name             = module.application.app_service_name
  container_registry_domain    = module.application.acr_login_server
  container_registry_username  = module.application.acr_admin_username
  container_registry_password  = module.application.acr_admin_password
  container_repository         = local.container_repository
  github_repo_id               = var.github_repo_id
  github_branch                = var.github_branch
  github_service_connection_id = var.github_service_connection_id
  azure_pipelines_yml_path     = var.azure_pipelines_yml_path
}
